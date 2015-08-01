require 'sinatra/base'
require 'haml'
require 'yaml'
require 'digest/md5'
require 'pp'

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
      unless session[:id]
        redirect '/signin'
        return
      end

      # メールアドレスがなければ、すみませんページ

      # それ以外ならばアイコンがあればアイコン表示。なければデフォルト表示
      md5 = Digest::MD5.new.update( session[:mail] ).to_s
      @image_path = yml["surrogator"]["icon_dir"] + md5
      @error = session[:error]
      @id = session[:id]
      haml :home
    end

    post '/session' do
      #TODO LDAPログインをする。ログインできない場合エラー

      session[:id] = params[:id]
      session[:mail] = params[:id] + '@example.com' #TODO
      redirect '/home'
    end

    post '/upload' do
      unless session[:id]
        redirect '/signin'
        return
      end
      permit_ext = [".jpg",".JPG",".jpeg",".JPEG",".png",".PNG"]

      if params[:file]
        if permit_ext.any?{|elem| params[:file][:filename].include?(elem) }
          save_path = "#{yml["surrogator"]["icon_dir"]}#{session[:mail]}#{File.extname(params[:file][:filename])}"
          File.open(save_path, 'wb') do |f|
            p params[:file][:tempfile]
            f.write params[:file][:tempfile].read
          end
          #TODO 画像をフォルダに上書きし、php実行
          session[:error] = nil
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
