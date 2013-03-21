# RULES ASSUMPTIONS
# You earn crystals for moving even when doing a Line Over

class Piece::Stone < Piece
  def self.is_stone?
    true
  end

  def move_to(space, pass = true)
    player = self.player
    player.add_crystals(val)
    player.save
    super(space, pass)
  end

  def line_over
    if self.in_last_row?
      self.player.add_crystals(val)
      self.die
      self.game.wait_for(self)
      self.waiting_state = 'reward'
      self.save
    end
  end

  def player_input(args)
    choosing_player = args[:player]
  
    return false unless choosing_player == self.player
  
    case self.waiting_state

    when 'reward'
      if args[:target] == 'crystals'
        self.player.add_crystals(10)
        self.game.wait_for(nil)
        self.waiting_state = nil
        self.save

        self.game.pass_turn
      elsif args[:reward] == 'resurrect'
        self.waiting_state = 'piece'
        self.save
      else
        return false
      end

    when 'piece'
      piece = args[:target]
      if piece.player == choosing_player &&
         !piece.kind_of?(Stone) &&
         piece.in_graveyard?
        self.target_piece = piece
        self.waiting_state = 'space'
        self.save
      else
        return false
      end

    when 'space'
      target_space = args[:target]
      if target_space.summon_square == self.player.num &&
         !target_space.occupied?
        self.target_piece.update_attributes(:in_graveyard => false, :space => target_space)
        self.waiting_state = nil
        self.save

        self.game.wait_for(nil)

        self.game.pass_turn
      else
        return false
      end
    else
      return false
    end
  end

  def is_creature?
    false
  end
end
