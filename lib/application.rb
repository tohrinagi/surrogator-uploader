require 'bundler/setup'
require 'sinatra/base'
require 'haml'
require 'yaml'
require 'digest/md5'
require 'surrogator-uploader/ldapauth'

module SurrogatorUploader
  class Application < Sinatra::Base

    set :haml, escape_html: true
    enable :sessions
    set :session_secret, '9lkjsd98t-2jqkt9jb'
    set :public, File.dirname(__FILE__) + '/public'


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
      redirect to('/signin')
    end

    get '/signin' do
      @id = session[:id]
      @error = session[:error]
      haml :signin
    end

    get '/signout' do
      session.clear
      redirect to('/signin')
    end

    get '/home' do
      # LDAPログインできていなければエラーページ
      unless session[:login]
        redirect to('/signin')
        return
      end

      # メールアドレスがなければ、使えないようにする
      @error = session[:error]
      @id = session[:id]
      if session[:mail] && !session[:mail].empty?
        @image_path = yml["surrogator"]["url"] + Digest::MD5.new.update( session[:mail] ).to_s + "?#{Time.now.to_i}"
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
        user = LdapAuth.authenticate(params[:id], params[:password])
      if user.nil?
        session[:error] = "ログインできませんでした"
        session[:login] = nil
        redirect to('/signin')
        return
      end
      session[:error] = nil
      session[:login] = true
      session[:mail] = user.attribute[:mail][0]
      redirect to('/home')
    end

    post '/upload' do
      unless session[:login]
        redirect to('/signin')
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
      redirect to('/home')
    end

    not_found do
      haml :not_found
    end
  end
end
