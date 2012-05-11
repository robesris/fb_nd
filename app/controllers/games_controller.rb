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
end
