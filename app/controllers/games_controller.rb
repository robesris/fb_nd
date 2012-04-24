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
    end

    render '/game' 
  end
end
