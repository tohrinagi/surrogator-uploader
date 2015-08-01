require 'sinatra/base'
require 'haml'
require 'yaml'
require 'digest/md5'
require 'surrogator-uploader/ldapauth'

module SurrogatorUploader
  class Application < Sinatra::Base

    set :haml, escape_html: true
    enable :sessions
    set :session_secret, 'YOUR_SECRET_SECRET_KEY'

    helpers do
      def yml
        @yml ||= YAML.load_file( File.dirname(__FILE__) + '/../setting.yml')
      end
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get '/' do
      redirect '/signin'
    end

    get '/signin' do
      @id = session[:id]
      @error = session[:error]
      haml :signin
    end

    get '/signout' do
      session.clear
      redirect '/signin'
    end

    get '/home' do
      # LDAPログインできていなければエラーページ
      unless session[:login]
        redirect '/signin'
        return
      end

      # メールアドレスがなければ、使えないようにする
      @error = session[:error]
      @id = session[:id]
      if session[:mail] && !session[:mail].empty?
        @image_path = yml["surrogator"]["url"] + Digest::MD5.new.update( session[:mail] ).to_s
        @submit_enabled = true
      else
        @error = "メールアドレスがないため、アイコンを使うことができません"
        @submit_enabled = false
      end
      haml :home
    end

    post '/session' do
      LdapAuth.initialize(yml["ldap"]["server"], yml["ldap"]["port"], yml["ldap"]["base"])
      session[:id] = params[:id]
      begin
        user = LdapAuth.authenticate(params[:id], params[:password])
      rescue
        session[:error] = "ログインできませんでした"
        session[:login] = nil
        redirect '/signin'
        return
      end
      session[:error] = nil
      session[:login] = true
      session[:mail] = user.mail
      redirect '/home'
    end

    post '/upload' do
      unless session[:login]
        redirect '/signin'
        return
      end
      permit_ext = [".jpg",".JPG",".jpeg",".JPEG",".png",".PNG"]

      if params[:file]
        #拡張子があっているか確認
        if permit_ext.any?{|elem| params[:file][:filename].include?(elem) }
          save_path = "#{yml["surrogator"]["icon_dir"]}#{session[:mail]}#{File.extname(params[:file][:filename])}"
          File.open(save_path, 'wb') do |f|
            p params[:file][:tempfile]
            f.write params[:file][:tempfile].read
          end
          # php surrogator.php を動かす
          result = system("php #{yml["surrogator"]["php_path"]}")
          if result
            session[:error] = nil
          else
            session[:error] = "アイコンの更新ができませんでした"
          end
        else
          session[:error] = "jpg または png ファイルをアップロードしてください"
        end
      else
        session[:error] = "アップロードに失敗しました"
      end
      redirect '/home'
    end

  end
end
