class Space < ActiveRecord::Base
  attr_accessible :board_id, :col, :piece_id, :row

  belongs_to :board
  belongs_to :piece

  GRAVEYARD = -4

  def occupied?
    self.piece.present?
  end
end