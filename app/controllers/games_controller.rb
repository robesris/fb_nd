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
    game = current_game
    piece_name = params[:piece_name]
    space = get_space(game)
    player = current_player(game)

    text = ""
    status = "success"

    if new_piece = player.draft(piece_name, space)
      game.add_event(
        :player_num => player.opponent.num, 
        :action => 'draft',
        :to => params[:space],
        :options => { :piece_name => piece_name }
      )
      text = new_piece.unique_name
    else
      text = "Can't draft that piece there!"
      status = "failure"
    end

    render :json => { :text => text, :status => status }.to_json
  end

  def move
    begin
      game = current_game

      return false unless game.phase == 'play'

      space = get_space(game)
      player = current_player(game)
      piece = player.pieces.where(:unique_name => params[:piece_unique_name]).first

      result = nil

      if player.move(piece, space)
        result = { :status => 'success', :p1_crystals => game.player1.crystals, :p2_crystals => game.player2.crystals }
        game.add_event(
          :player_num => player.opponent.num,
          :action => 'move',
          :to => params[:space],
          :piece => piece,
          :options => result
        )
      else
        result = { :status => 'failure', :message => "Can't move that piece there!" }
      end

      render :json => result
    rescue => e
      render :nothing => true
    end
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
          events = game.events.where(:player_num => player.num) #.reject{ |e| e.action == 'move' }
          events.each { |e| e.destroy }
          player.update_attribute(:checking_for_events, false)
        rescue ActiveRecord::Rollback
          render :json => []  # return nothing if the transaction is rolled back
        end
      end
    end

    events = events.map{ |event| { :action => event.action, :piece_unique_name => event.piece && event.piece.unique_name, :to => event.to, :options => event.options } }
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

  def get_space(game)
    space_string = params[:space]
    col = space_string.slice(-3)
    row = space_string.slice(-1)

    if space_string.slice(0, 4) == 'keep'
      pnum = col
      keep_space_num = row.to_i - 1
      game.playernum(pnum).keep[keep_space_num]
    else
      game.board.space(col, row)
    end
  end

end
