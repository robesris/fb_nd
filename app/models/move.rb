class Move < ActiveRecord::Base
  attr_accessible :capture_allowed, :earn_crystals, :pass, :piece, :player, :space

  belongs_to :piece
  belongs_to :player
  belongs_to :space

  after_create :apply_move

  validate do |move|
    #debugger if piece.name == "Agu"
    move.player_must_be_active
    move.player_must_not_have_active_pieces
    move.must_be_able_to_reach_destination_space
    move.must_be_able_to_capture if self.space.occupied?
  end

  # validations
  def player_must_be_active
    errors.add(:player, "is not active") unless self.player.is_active?
  end

  def player_must_not_have_active_pieces
    errors.add(:player, "already has an active piece") if self.player.active_piece
  end

  def must_be_able_to_reach_destination_space
    errors.add(:piece, "cannot reach #{self.space.humanize}") unless self.piece.can_reach?(space)
  end

  def must_be_able_to_capture
    errors.add(:player, "cannot capture your own piece") if target_piece.player == self.player
  end

  def apply_move
    self.player.activate_piece(piece)
    target_piece && self.piece.kapture(target_piece)
    self.piece.move_to(space, pass)
  end


  private

  def target_piece
    self.space.piece
  end

end
