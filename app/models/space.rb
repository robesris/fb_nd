class Space < ActiveRecord::Base
  attr_accessible :board_id, :col, :piece_id, :row, :half_crystal, :summon_space, :player

  belongs_to :board
  belongs_to :piece
  belongs_to :player

  GRAVEYARD = -4

  def humanize
    "#{col_letter}-#{row}"
  end

  def occupied?
    self.piece.present?
  end

  def adjacent_to_nav?(player)
    nav_space = player.pieces.select{ |p| p.kind_of?(Piece::Nav) }.first.space
    (nav_space.col - self.col).abs <= 1 && (nav_space.row - self.row).abs <= 1
  end


  private

  def col_letter
    ['A', 'B', 'C', 'D', 'E', 'F', 'G'][self.col - 1]
  end
end
