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
  cards = %W[A 2 3 4 5 6 7 8 9 10 J Q K]
  suits = %w[H S C D]
  session[:deck] = cards.product(suits).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times {session[:dealer_cards] << session[:deck].shift}
  2.times {session[:player_cards] << session[:deck].shift}

  erb :game
end