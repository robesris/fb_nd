class Kom < Piece
  def val
    8
  end

  def side1
    [ 0, 0, 0, 0, 0,
      1, 1, 1, 1, 1,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ] 
  end

  def flip
    if super(false)
      self.game.wait_for(self)
      self.waiting_state = 'piece'
      self.save
    end
  end

  def player_input(args)
    choosing_player = args[:player]
    target = args[:target]
    if self.waiting_state == 'piece' &&
       choosing_player == self.player && 
       target.is_creature? &&
       target.player == self.player &&
       target.on_board? &&
       target != self
      target.move_to_keep
      self.waiting_state = nil
      self.save
      self.die
      self.game.wait_for(nil)
    else
      return false
    end
  end

  def cancel
    if self.waiting_state == 'piece' && self.flipped? # second condition is redundant, but this may be a bit clearer
      self.unflip
      self.waiting_state = nil
      self.save
    end 
  end
end
