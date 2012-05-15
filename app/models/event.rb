class Event < ActiveRecord::Base
  attr_accessible :player_num, :action, :from, :to, :options
  
  serialize :options
  
  belongs_to :game
end
