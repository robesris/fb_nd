class Board < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :spaces
  has_many :graveyard_pieces, :class_name => Piece

  def initialize(params = nil, options = {})
    super(params)
    1.upto(7) do |row|
      1.upto(7) do |col|
        self.spaces << Space.create(:row => row, :col => col)
      end
    end
  end

  def space(row, col)
    self.spaces.where(:row => row, :col => col).first
  end

  def graveyard
    self.graveyard_pieces
  end  

  def empty_graveyard
    self.graveyard_pieces = []
    self.save
  end
end
