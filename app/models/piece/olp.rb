class Olp < Piece
  def val
    4
  end

  def side1
    [ 0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 0, 0 ]
  end

  def side2
    [ 0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 0, 0 ]
  end

  def guard?
    true
  end

  def flip
    if super(false)
      self.game.wait_for(self)
      self.waiting_state = 'piece_1'
      self.save
    end
  end

  def waiting_message
    case self.waiting_state
    when 'piece_1'
      "Choose a piece."
    when 'piece_2'
      "Choose a piece to switch places with."
    end
  end
end
