require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN = 17
INITIAL_POT_AMOUNT = 1000

helpers do
  def total (cards)
    arr = cards.map{|value|value [1]}
total = 0
    arr.each do |value|
      if value == 'A'
        total = total + 11
      elsif value.to_i == 0
        total = total + 10
      else
        total = total + value.to_i
      end
    end

    arr.select{|value|value == 'A'}.count.times do
      if total <= 21
        break
      end
        total = total - 10
    end
  total
  end

  def card_image(card) #['H', 'A']
    suit = case card[0]
        when 'H' then 'hearts'
        when 'S' then 'spades'
        when 'D' then 'diamonds'
        when 'C' then 'clubs'
    end

    value = card[1]
    if ['A','J','Q','K'].include?(value)
      value = case card[1]
        when 'A' then 'ace'
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
      end
    end
    "<img src = '/images/cards/#{suit}_#{value}.jpg' class='card_image' >"
  end

  def win!(msg)
    @winner = "Congratulations, #{msg}.  #{session[:player_name]} won #{session[:bet_amount]}"
    session[:player_pot] += session[:bet_amount]
    @play_again_buttons = true
  end

  def lose!(msg)
    @loser = "Ooops sorry, #{msg}.  #{session[:player_name]} lost #{session[:bet_amount]}"
    session[:player_pot] -= session[:bet_amount]
    @play_again_buttons = true
  end

  def tie!(msg)
    @winner = "It is a tie. #{msg}"
    @play_again_buttons = true
  end

end

  before do
    @show_hit_stay_button = true
  end

get '/' do
  if session[:player_name]
    #redirect '/game'
    redirect '/bet'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do
  if params[:username].empty?
    @error = "Name can not be empty!"
    halt erb :new_player
  end
  session[:player_name] = params[:username]
  #redirect '/game'
  redirect '/bet'
end


get '/bet' do
  session[:bet_amount] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Must make a bet!!"
    halt erb :bet
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Bet amount cannot exceed the pot amount. (#{session[:player_pot]})"
    halt erb :bet
  else
  session[:bet_amount] = params[:bet_amount].to_i
  redirect '/game'
  end
end


get '/game' do
  session[:turn] = session[:player_name]

  suit = ['S', 'H', 'D', 'C']
  value = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  session[:deck] = suit.product(value).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []

  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  erb :game
end


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    win!("#{session[:player_name]} hit blackjack!")

    @show_hit_stay_button = false
  elsif player_total > BLACKJACK_AMOUNT
    lose!( "#{session[:player_name]} is busted.")

    @show_hit_stay_button = false
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @show_hit_stay_button = false
  @success = "#{session[:player_name]} choses to stay."
  redirect '/game/dealer'

end

get '/game/dealer' do
  session[:turn] = "dealer"

  @show_hit_stay_button = false
  dealer_total = total(session[:dealer_cards])
  if dealer_total == BLACKJACK_AMOUNT
    lose!("dealer hits a blackjack")

  elsif dealer_total > BLACKJACK_AMOUNT
    win!("dealer is busted!")

  elsif dealer_total >= DEALER_MIN  #17, 18, 19, 20,
    redirect '/game/compare'
  else  #< 17
    @show_dealer_hit_button = true
  end
erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end


get '/game/compare' do
   @show_hit_stay_button = false
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])
  if player_total > dealer_total
    win!("#{session[:player_name]} stays at #{player_total} and dealer stays at #{dealer_total}. ")

  elsif player_total < dealer_total

    lose!("#{session[:player_name]} stays at #{player_total} and dealer stays at #{dealer_total}. ")
  else

    tie!("both #{session[:player_name]} and dealer stay at #{player_total}. ")
  end
  erb :game, layout: false
end


get '/game_over' do
erb :game_over
end









