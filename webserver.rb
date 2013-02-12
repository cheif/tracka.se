require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require './scraper.rb'
require 'json'
require 'haml'
require 'rack/coffee'

use Rack::Coffee,
    :root => 'public',
    :urls => '/js'


get '/' do
    haml :index
end

get '/detail' do
    haml :detail
end

get '/tracking/:kollinr' do
    result = Scraper.All(params[:kollinr]).to_json
    return result
end
