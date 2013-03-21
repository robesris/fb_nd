class Piece
  module Constants
    MOVEMENT_GRID_WIDTH = 5
    MOVEMENT_GRID_HEIGHT = 5
    MAX_COL_MOVE = (MOVEMENT_GRID_WIDTH - 1) / 2 # => 2
    MAX_ROW_MOVE = (MOVEMENT_GRID_HEIGHT - 1) / 2 # => 2
    MOVEMENT_GRID_CENTER = MOVEMENT_GRID_WIDTH * MAX_ROW_MOVE + MAX_COL_MOVE # => 12

    BLACK							= [ 0, 0, 0, 0, 0,
                    0, 0, 1, 0, 0,
                    0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0 ]

    RED								= [ 0, 0, 0, 0, 0,
                   0, 1, 1, 1, 0,
                   0, 0, 0, 0, 0,
                   0, 0, 0, 0, 0,
                   0, 0, 0, 0, 0 ]

    GOLD							= [ 0, 0, 0, 0, 0,
                   0, 1, 1, 1, 0,
                   0, 1, 0, 1, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 0, 0, 0 ]

    KING							= [ 0, 0, 0, 0, 0,
                   0, 1, 1, 1, 0,
                   0, 1, 0, 1, 0,
                   0, 1, 1, 1, 0,
                   0, 0, 0, 0, 0 ]

    QUEEN							= [ 0, 0, 0, 0, 0,
                    0, :ul, :up, :ur, 0,
                    0, :lt, 0, :rt, 0,
                    0, :dl, :dn, :dr, 0,
                    0, 0, 0, 0, 0 ]

    ROOKLIKE					= [ 0, 0, 1, 0, 0,
                     0, 0, 1, 0, 0,
                     1, 1, 0, 1, 1,
                     0, 0, 1, 0, 0,
                     0, 0, 1, 0, 0 ]

    BISHOPLIKE				= [ 1, 0, 0, 0, 1,
                      0, 1, 0, 1, 0,
                      0, 0, 0, 0, 0,
                      0, 1, 0, 1, 0,
                      1, 0, 0, 0, 1 ]
  end
end
