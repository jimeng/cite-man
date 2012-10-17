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

ActiveRecord::Schema.define(:version => 20121016170838) do

  create_table "people", :force => true do |t|
    t.string   "family_name"
    t.string   "full_name"
    t.string   "given_name"
    t.string   "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "preferredStyle"
    t.string   "preferred_locale"
  end

  create_table "sources", :force => true do |t|
    t.string   "person_id"
    t.string   "provider"
    t.string   "name"
    t.string   "client_id"
    t.string   "client_key"
    t.string   "client_secret"
    t.string   "client_type"
    t.string   "uid"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "default_style"
  end

end