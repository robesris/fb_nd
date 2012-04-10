class Game < ActiveRecord::Base
  attr_accessible :player1, :player2

  belongs_to :player1, :class_name => Player
  belongs_to :player2, :class_name => Player

  def playernum(num)
    num = num.to_i
    if num == 1
      player1
    elsif num == 2
      player2
    else
      nil
    end
  end
end
