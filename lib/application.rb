# coding: utf-8

require 'sinatra/base'
require 'haml'

module SurrogatorUploader
  class Application < Sinatra::Base

    get '/' do
      redirect '/signin'
    end

    get '/signin' do
      haml :signin
    end

    get '/home' do
      # LDAPログインできていなければエラーページ
      # メールアドレスがなければ、すみませんページ
      # それ以外ならばアイコンがあればアイコン表示。なければデフォルト表示
      haml :home
    end

    post '/session' do
      # LDAPログインをする。ログインできない場合エラー
      redirect '/home'
    end

    post '/upload' do
      # 画像をフォルダに上書きし、php実行
      redirect '/home'
    end

  end
end
