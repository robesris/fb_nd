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
      self.waiting_state = 'pieces'
      self.save
    end
  end

  def prompts
    [ { :message => 'Choose a piece.', :target => :piece },
      { :message => 'Choose a piece to switch places with.', :target => :piece } ]
#    case self.waiting_state
#    when 'piece_1'
#      "Choose a piece."
#    when 'piece_2'
#      "Choose a piece to switch places with."
#    end
  end

  def player_input(args)
    choosing_player = args[:player]

    return false unless super(choosing_player)
    piece_1 = args[:piece_1]
    piece_2 = args[:piece_2]

    # Won't work on Nav
    return false if piece_1.kind_of?(Piece::Nav) || piece_2.kind_of?(Piece::Nav)

    if piece_1.on_board? && piece_2.on_board?
      piece_1_space = piece_1.space
      piece_1.space = piece_2.space
      piece_2.space = piece_1_space

      piece_1.save && piece_2.save
      self.game.pass_turn
    end
  end
end
