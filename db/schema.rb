# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130319221000) do

  create_table "boards", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "game_id"
    t.integer  "piece_id"
  end

  create_table "events", :force => true do |t|
    t.integer  "game_id"
    t.integer  "player_num"
    t.string   "action"
    t.string   "from"
    t.string   "to"
    t.string   "options"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "piece_id"
  end

  create_table "games", :force => true do |t|
    t.integer  "player1_id"
    t.integer  "player2_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "active_player_id"
    t.integer  "winner_id"
    t.integer  "waiting_for_id"
    t.string   "phase"
    t.string   "code"
  end

  create_table "moves", :force => true do |t|
    t.integer  "player_id"
    t.integer  "piece_id"
    t.integer  "space_id"
    t.boolean  "earn_crystals",   :default => true
    t.boolean  "capture_allowed", :default => true
    t.boolean  "pass"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "pieces", :force => true do |t|
    t.string   "name"
    t.integer  "player_id"
    t.boolean  "flipped"
    t.string   "type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "board_id"
    t.boolean  "in_graveyard"
    t.integer  "target_piece_id"
    t.string   "waiting_state"
    t.string   "unique_name"
  end

  create_table "players", :force => true do |t|
    t.integer  "num"
    t.integer  "crystals"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "game_id"
    t.integer  "active_piece_id"
    t.boolean  "in_check_this_turn"
    t.boolean  "ready"
    t.string   "secret"
    t.boolean  "checking_for_events"
  end

  create_table "spaces", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.integer  "piece_id"
    t.integer  "board_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "half_crystal"
    t.integer  "summon_space"
    t.integer  "player_id"
  end

end
