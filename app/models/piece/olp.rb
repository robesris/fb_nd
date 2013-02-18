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
     
    unique_name_1 = args[:prompts]['0']['unique_name']
    unique_name_2 = args[:prompts]['1']['unique_name']

    game = self.game
    piece_1 = choosing_player.pieces.where(:unique_name => unique_name_1).first
    piece_2 = choosing_player.pieces.where(:unique_name => unique_name_2).first

    # Won't work on Nav
    return false if piece_1.kind_of?(Piece::Nav) || piece_2.kind_of?(Piece::Nav)

    if piece_1.on_board? && piece_2.on_board?
      piece_1_space = piece_1.space
      piece_1.space = piece_2.space
      piece_2.space = piece_1_space

      piece_1.save && piece_2.save
      self.game.pass_turn

      # Even though this is only necessary because of the UI, I think it's simpler to put it
      # in the model rather than create another controller or controller action just for the
      # sake of this piece's ability
      return [ { :action => :move, :piece => piece_1, :to => piece_1.space },
               { :action => :move, :piece => piece_2, :to => piece_2.space } ]
    end
  end
end
