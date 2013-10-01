require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_STAY = 17
INITIAL_POT_AMOUNT = 500
CHIP_1_VAL = 5
CHIP_2_VAL = 10
CHIP_3_VAL = 25
CHIP_4_VAL = 50

helpers do
  def total(cards, flop=false) # cards is [["H", "3"], ["D", "J"], ... ]
    arr = flop && session[:state] < 3 ? [cards.first].map{|e| e[1]} : cards.map{|e| e[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    #correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def card_image(card) # ['H', '4']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "/images/cards/#{suit}_#{value}.jpg"
  end

  def winner!(msg, blackjack=false)
    session[:player_pot] = session[:player_pot] + (session[:player_bet] * (blackjack ? 1.5 : 1)).to_i
    @winner = "<strong>Win</strong>"
    @dealer = "<strong>#{msg}</strong>"
  end

  def loser!(msg)
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @loser = "<strong>#{msg}</strong>"
    @dealer = "<strong>Win</strong>"
  end

  def tie!
    @tie = "<strong>Tie</strong>"
  end

  def create_deck
    # create a deck and put it in session
    suits = ['H', 'D', 'C', 'S']
    values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    session[:deck] = suits.product(values).shuffle! # [ ['H', '9'], ['C', 'K'] ... ]
  end

  def deal
    # deal cards
    session[:dealer_cards] = []
    session[:player_cards] = []
    2.times do
      session[:dealer_cards] << session[:deck].pop
      session[:player_cards] << session[:deck].pop
    end
  end

  def blackjack?
    total(session[:player_cards]) == BLACKJACK_AMOUNT ? true : false
  end

  def blackjack
    winner!("Lose", true)
    @blackjack = "<strong>BLACKJACK</strong>"
    session[:state] = 4
  end

  def bust?(cards)
    total(cards) > BLACKJACK_AMOUNT ? true : false    
  end

  def bust
    loser!("Bust")
    session[:state] = 4
  end

  def dealer_turn
    while total(session[:dealer_cards]) < DEALER_MIN_STAY
      session[:dealer_cards] << session[:deck].pop
    end
  end

  def who_won
    player_total = total(session[:player_cards])
    dealer_total = total(session[:dealer_cards])

    if dealer_total > BLACKJACK_AMOUNT
      winner!("Bust")
    elsif player_total == dealer_total
      tie!
    elsif player_total < dealer_total
      loser!("Lose")
    else
      winner!("Lose")
    end
  end
end

get '/' do
  session.clear
  session[:state] = 0
  response.set_cookie 'state', session[:state]
  session[:player_pot] = INITIAL_POT_AMOUNT
  session[:chip_1] = CHIP_1_VAL
  session[:chip_2] = CHIP_2_VAL
  session[:chip_3] = CHIP_3_VAL
  session[:chip_4] = CHIP_4_VAL
  erb :game
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  session[:state] = 1
  response.set_cookie 'state', session[:state]
  redirect '/bet'
end

get '/bet' do
  erb :game, layout: false
end

get '/bet_amount' do
  halt erb(:game) if session[:state] != 1
  session[:bet_amount] = session[:bet_amount].to_i + params[:bet_add].to_i
  erb :game, layout: false
end

post '/bet' do
  if session[:bet_amount].nil? || session[:bet_amount].to_i == 0
    @error = "Must make a bet."
    halt erb(:game)
  elsif session[:bet_amount].to_i > session[:player_pot]
    @error = "Bet amount cannot be greater than what you have ($#{session[:player_pot]})"
    halt erb(:game)
  else #happy path
    session[:player_bet] = session[:bet_amount]
    session[:state] = 2
    response.set_cookie 'state', session[:state]
    create_deck
    deal
    redirect :game
  end
end

post '/rebet' do
    session[:player_bet] = session[:bet_amount] = session[:prev_bet]
    session[:state] = 2
    create_deck
    deal
    redirect :game
end

get '/game' do
  if true
    total(session[:dealer_cards]) == BLACKJACK_AMOUNT ? tie! : blackjack
  end
  erb :game, layout: false
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  bust if bust?(session[:player_cards])
  erb :game, layout: false
end

post '/game/player/stay' do
  session[:state] = 3
  dealer_turn
  who_won
  session[:state] = 4
  erb :game, layout: false
end

get '/again' do
  session[:prev_bet] = session[:player_bet]
  session[:bet_amount] = 0
  session[:player_bet] = 0
  session[:state] = 1
  response.set_cookie 'state', session[:state]
  redirect :bet
end