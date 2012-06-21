class Event < ActiveRecord::Base
  attr_accessible :player_num, :action, :from, :to, :options, :piece
  
  serialize :options
  
  belongs_to :game
  belongs_to :piece
end
