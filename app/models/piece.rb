class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type
  
  belongs_to :player
  has_one :board, :through => :space
  has_one :space

  def initialize(params = nil, options = {})
    super(params)
    self.name = self.class.to_s
  end

  def row
    self.space && self.space.row
  end

  def col
    self.space && self.space.col
  end

  def move(row, col)
    puts "ROW: #{row} COLUMN: #{col}"
    target_space = self.board.space(row, col)
    
    # capture the occupying piece, if present
    if target_space.occupied?
      target_space.piece.die
    end
    self.space = target_space
    self.save
  end

  def die
    puts "SPACE: " + self.space.inspect
    self.in_graveyard = true
    self.space = nil
    self.save
  end
end
