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

  def same_col_as?(space)
    self.col == space.col
  end

  def same_row_as?(space)
    self.row == space.row
  end

  def diagonal_to?(space)
    (self.col - space.col).abs == (self.row - space.row).abs
  end

  def has_line_to?(space)
    self.same_col_as?(space) || self.same_row_as?(space) || self.diagonal_to?(space)
  end

  private

  def col_letter
    ['A', 'B', 'C', 'D', 'E', 'F', 'G'][self.col - 1]
  end
end
