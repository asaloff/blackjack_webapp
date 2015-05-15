require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  
  def calculate_total(cards) 
    arr = cards.map { |e| e[1] }

    total = 0
    arr.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0 # J, Q, K
        total += 10
      else
        total += value.to_i
      end
    end

    if arr.any? { |card| card.include?("A") }
      arr.each do |card|
        total -= 10 if total > BLACKJACK_AMOUNT && card.include?("A")
      end
    end
    total
  end

  def display_card(card)
    suit = case card[0]
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
      when 'H' then 'hearts'
    end 

    case card[1]
      when 'J' then value = 'jack'
      when 'Q' then value = 'queen'
      when 'K' then value = 'king'
      when 'A' then value = 'ace'
      else
        value = card[1].to_i
    end

    "<img class='card_resize' src='/images/cards/#{suit}_#{value}.jpg'>"
  end

  def blackjack(player)
    if player == 'dealer'
      @error = "Dealer has Blackjack...Bummer."
    else
      @success = "#{session[:player_name]} has Blackjack!!"
    end
    @show_hit_stay_buttons = false
    @replay = true
  end

  def busted(player)
    if player == 'dealer'
      @success= "Dealer busts!! #{session[:player_name]} wins!!"
    else
      @error = "#{session[:player_name]} busts! Maybe next time."
    end
    @show_hit_stay_buttons = false
    @replay = true
  end

  def compare_cards
    @show_hit_stay_buttons = false
    @player_turn = false

    player_total = calculate_total(session[:player_cards])
    dealer_total = calculate_total(session[:dealer_cards])

    if player_total > dealer_total
      @success = "#{session[:player_name]}'s cards are better! #{session[:player_name]} wins!!"
    elsif player_total < dealer_total
      @error = "Dealer's cards are better. #{session[:player_name]} loses."
    elsif player_total == dealer_total
      @neutral = "#{session[:player_name]}'s and the Dealer's cards are the same. It's a tie."
    end
    @replay = true
  end

  def display_play_again_buttons
    "<p class='play-again'><strong>Would you like to play again?</strong> 
    <a class='btn btn-primary' href='/game'>Yes</a> <a class='btn' href='/end_game'>No</a></p>"
  end

end

before do
  @show_hit_stay_buttons = true
  @show_dealer_next_card_button = false
  @player_turn = true
end

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

  if params['player_name'].empty?
    @error = 'Required feild is empty.'
    halt erb :player_name_form
  end

  session[:player_name] = params['player_name'].capitalize
  redirect '/game'
end

get '/game' do
  cards = %W[A 2 3 4 5 6 7 8 9 10 J Q K]
  suits = %w[H S C D]
  session[:deck] = suits.product(cards).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times {session[:dealer_cards] << session[:deck].shift}
  2.times {session[:player_cards] << session[:deck].shift}

  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    blackjack('player')
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].shift
  total = calculate_total(session[:player_cards])
  if total > BLACKJACK_AMOUNT
    busted('player')
  elsif total == BLACKJACK_AMOUNT
    blackjack('player')
  end
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_stay_buttons = false
  @player_turn = false

  total = calculate_total(session[:dealer_cards])
  
  if total > BLACKJACK_AMOUNT
    busted('dealer')
  elsif total == BLACKJACK_AMOUNT
    blackjack('dealer')
  elsif total < DEALER_MIN_HIT
    @show_dealer_next_card_button = true
  else
    redirect '/game/compare_cards'
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].shift
  redirect '/game/dealer'
  erb :game
end

get '/game/compare_cards' do
  compare_cards
  erb :game
end 

get '/end_game' do
  erb :end_game
end




