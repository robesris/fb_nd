class Board < ActiveRecord::Base
  #attr_accessible :title, :body

  has_many :spaces
  has_many :graveyard_pieces, :class_name => Piece

  def initialize(params = nil, options = {})
    super(params)
    1.upto(7) do |row|
      1.upto(7) do |col|
        half_crystal = (row == 4 && (2..6).include?(col))
        summon_space = if (row == 1 && col != 4) || (row == 2 && col == 1) || (row ==2 && col == 7)
                         1
                       elsif (row == 7 && col != 4) || (row == 6 && col == 1) || (row ==6 && col == 7)
                         2
                       else
                         nil
                       end
        self.spaces << Space.create(:row => row, :col => col, :half_crystal => half_crystal, :summon_space => summon_space)
      end
    end
  end

  def icol(col)
    if col.is_a?(String)
      col.ord - 96
    else
      col
    end
  end

  def space(col, row)
    col = icol(col)
    row = row.to_i
    self.spaces.where(:row => row, :col => col).first
  end

  def graveyard
    self.graveyard_pieces
  end  

  def empty_graveyard
    self.graveyard_pieces = []
    self.save
  end

  def nav_space(args)
    self.spaces.where(:col => 4, :row => args[:player].num == 1 ? 1 : 7).first
  end
end
