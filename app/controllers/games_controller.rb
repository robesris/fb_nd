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
      @all_piece_klasses = Piece.all_piece_klasses
    end

    render '/game' 
  end

  def join
    @game_code = params[:game_code]
    @player_secret = params[:player_secret]

    render :template => 'game'
  end
end
