class Tiny < Piece
  def val
    14
  end

  def side1
    [ 0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ]
  end

  def flip
    super(false)
    self.game.wait_for(self)
    self.waiting_state = 'piece'
    self.save 
  end

  def player_input(args)
    if self.waiting_state == 'piece'
      choosing_player = args[:player]
      target = args[:target]

      if choosing_player == self.player &&
         target.kind_of?(Piece) &&
         !target.kind_of?(Piece::Nav) &&
         target.on_board?
        target.die
        self.die
        self.waiting_state = nil
        self.save

        self.game.wait_for(nil)

        self.game.pass_turn
      else
        return false
      end
    end
  end
end
