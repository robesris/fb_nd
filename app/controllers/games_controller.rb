class GamesController < ApplicationController
  def new
    render :template => 'game'
  end

  def create(params = {})
    @game = nil
    
    if params.empty?
      @game = Game.create
      @game.default_setup
      @game.save

      @me = @game.player1
      @me.update_attribute(:secret, Game.generate_secret)

      @all_piece_klasses = Piece.all_piece_klasses

      @game_code = @game.code
      @player_secret = @me.secret
    end

    render '/game' 
  end

  def join
    @game_code = params[:game_code]
    @game = Game.where(:code => @game_code).first
    @player_secret = params[:player_secret]
    if @player_secret == 'new_player'
      # new_player should only work once and will initialize the secret for the player
      # this way, the player who creates the game can't access the other player's view
      @me = @game.players.where(:secret => nil).first
      @me.update_attribute(:secret, Game.generate_secret)

      redirect_to join_game_path(:game_code => @game_code, :player_secret => @me.secret)
    else
      @me = @game.players.where(:secret => @player_secret).first
      @all_piece_klasses = Piece.all_piece_klasses

      render :template => 'game'
    end
  end

  def draft
    
    game_code = params[:game_code]
    game = Game.where(:code => game_code).first
    player_secret = params[:player_secret]
    piece_name = params[:piece_name]
    space_string = params[:space]
    
    col = space_string.slice(-3)
    row = space_string.slice(-1)
    
    space = if space_string.slice(0, 4) == 'keep'
      pnum = col
      keep_space_num = row.to_i - 1
      game.playernum(pnum).keep[keep_space_num]
    else
      game.board.space(col, row)
    end
    
    player = game.players.where(:secret => player_secret).first
    text = "ok"

    if player.draft(piece_name, space)
      game.add_event(
        :player_num => player.opponent.num, 
        :action => 'draft',
        :to => params[:space],
        :options => { :piece_name => piece_name }
      )
    else
      text = "Can't draft that piece there!"
    end

    render :json => text.to_json
  end

  def init
    # get rid of all events for this player because we would have just drawn the board anyway
    game_code = params[:game_code]
    game = Game.where(:code => game_code).first
    player_secret = params[:player_secret]
    player = game.players.where(:secret => player_secret).first

    events = game.events.where(:player_num => player.num)
    events.each { |e| e.destroy }

    render :nothing => true
  end

  def ready
    game = current_game
    player = current_player(game)

    player.update_attribute(:ready, true)
    if player.opponent.ready?
      game.start_game
    end

    render :json => 200
  end

  def check_for_events
    game_code = params[:game_code]
    game = Game.where(:code => game_code).first
    player_secret = params[:player_secret]
    player = game.players.where(:secret => player_secret).first

    events = []
    unless player.checking_for_events? || game.phase == 'setup'
      ActiveRecord::Base.transaction do
        begin
          player.update_attribute(:checking_for_events, true)
          events = game.events.where(:player_num => player.num)
          events.each { |e| e.destroy }
          player.update_attribute(:checking_for_events, false)
        rescue ActiveRecord::Rollback
          render :json => []  # return nothing if the transaction is rolled back
        end
      end
    end

    render :json => events.to_json
  end

  private

  def current_game
    game_code = params[:game_code]
    game = Game.where(:code => game_code).first
    game
  end

  def current_player(game)
    player_secret = params[:player_secret]
    player = game.players.where(:secret => player_secret).first
    player
  end
end
