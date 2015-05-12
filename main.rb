require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/get_username"
  end
end

get '/get_username' do
  erb :player_name_form
end

post '/set_player_name' do
  session[:player_name] = params['player_name']
  redirect '/game'
end

get '/game' do
  "Hello" + session[:player_name].to_s
end