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
      haml :home
    end

    post '/session' do
      redirect '/home'
    end

    post '/upload' do
      redirect '/home'
    end

  end
end
