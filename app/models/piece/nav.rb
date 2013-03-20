class Piece::Nav < Piece
  def val
    60
  end

  def side1
    Constants::KING
  end
  
  def move_to(args = {})
    self.player.update_attribute(:in_check_this_turn, self.in_check?)
    super(args)
  end

  def in_check?
    self.player.in_check?
  end

  def flip
    return false if self.in_check? || self.player.in_check_this_turn?
    if super
      self.player.win_game
    else
      return false
    end
  end

  def goal_over
    if self.player.empty_keep? && self.player.nav.in_last_row?
      self.player.win_game
    end 
  end

  def die
    super
    self.player.lose_game
  end

  def is_creature?
    false
  end
end
