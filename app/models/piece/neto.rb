# RULES ASSUMPTIONS
# Neto cannot use her flip power to put a piece on the space she is on

class Neto < Piece
  belongs_to :target_piece, :class_name => Piece

  def val
    5
  end

  def flip
    if super
      self.game.update_attribute(:waiting_for, self)
      self.waiting_state = 'piece'
      self.save
    end
  end

  def player_input(args)
    if self.waiting_state == 'piece'
      if args[:player] == self.player && 
         args[:target].kind_of?(Piece) &&
         args[:target].player == self.player &&
         args[:target].in_graveyard?
        self.target_piece = args[:target]
        self.waiting_state = 'space'
        self.save
      else
        return false
      end
    elsif self.waiting_state == 'space'
      if args[:player] == self.player &&
         args[:target].kind_of?(Space) &&
         !args[:target].occupied? &&
         args[:target].summon_space == self.player.num
        self.target_piece.update_attribute(:in_graveyard, false)
        self.target_piece.update_attribute(:space, args[:target])
        self.die
        self.waiting_state = nil
        self.save

        self.game.update_attribute(:waiting_for, nil)
      end
    else
      return false
    end
  end
end
