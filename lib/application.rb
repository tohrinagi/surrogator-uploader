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

    configure do
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get '/' do
      redirect '/signin'
    end

    get '/signin' do
      haml :signin
    end

    get '/home' do
      # LDAPログインできていなければエラーページ
      unless session[:id]
        redirect '/signin'
      end

      # メールアドレスがなければ、すみませんページ

      # それ以外ならばアイコンがあればアイコン表示。なければデフォルト表示
      yml = YAML.load_file( File.dirname(__FILE__) + '/../setting.yml')
      md5 = Digest::MD5.new.update( session[:mail] ).to_s
      @image_path = yml["surrogator"]["icon_dir"] + md5
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
      end
      permit_ext = [".jpg",".JPG",".jpeg",".JPEG",".png",".PNG"]

      if params[:file]
        if permit_ext.any?{|elem| params[:file][:filename].include?(elem) }
          yml = YAML.load_file( File.dirname(__FILE__) + '/../setting.yml')
          save_path = "#{yml["surrogator"]["icon_dir"]}#{session[:mail]}#{File.extname(params[:file][:filename])}"
          File.open(save_path, 'wb') do |f|
            p params[:file][:tempfile]
            f.write params[:file][:tempfile].read
          end
          #TODO 画像をフォルダに上書きし、php実行
        else
          @error = "jpg または png ファイルをアップロードしてください"
        end
      else
        @error = "アップロードに失敗しました"
      end
      redirect '/home'
    end

  end
end
