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

ActiveRecord::Schema.define(:version => 20171213043350) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "advitems", :force => true do |t|
    t.string   "provider_name"
    t.string   "provider_tel"
    t.string   "adv_link"
    t.string   "adv_photo"
    t.date     "end_date"
    t.integer  "creator_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "attendants", :force => true do |t|
    t.integer  "groupattendant_id"
    t.string   "name"
    t.string   "phone"
    t.integer  "curscore"
    t.string   "email"
    t.string   "regtype"
    t.integer  "registor_id"
    t.string   "teamname"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "player_id"
  end

  create_table "authcertunits", :force => true do |t|
    t.string   "unitname"
    t.string   "address"
    t.string   "tel"
    t.integer  "majorcontact_id"
    t.string   "unitlogo"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blacklists", :force => true do |t|
    t.integer  "gameholder_id"
    t.integer  "playerprofile_id"
    t.text     "player_name"
    t.text     "note"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "certifications", :force => true do |t|
    t.integer  "authcertunit_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "courtphotos", :force => true do |t|
    t.integer  "ttcourt_id"
    t.string   "photo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "gamecoholders", :force => true do |t|
    t.integer  "holdgame_id"
    t.integer  "co_holderid"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "gamegroups", :force => true do |t|
    t.integer  "holdgame_id"
    t.string   "groupname"
    t.string   "grouptype"
    t.integer  "noofplayers"
    t.integer  "noofbackupplayers"
    t.string   "scorelimitation"
    t.integer  "scorelow"
    t.integer  "scorehigh"
    t.datetime "starttime"
    t.integer  "gamefee"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "regtype"
    t.text     "double_score_sum_limitation"
    t.integer  "double_scorehigh"
    t.integer  "double_scorelow"
    t.boolean  "cancellation_deadline_flag",  :default => false
    t.datetime "cancellation_deadline"
    t.string   "minimal_LTTF_games_limited",  :default => "無限制(0顆星)"
    t.string   "authcerts"
    t.boolean  "need_authcert_flag",          :default => false
    t.string   "authcondition",               :default => "參賽次數&認證單位核可符合任一項即可"
    t.datetime "registration_deadline"
    t.boolean  "registration_deadline_flag",  :default => false
  end

  create_table "gameholders", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "courtname"
    t.string   "city"
    t.string   "county"
    t.string   "zipcode"
    t.text     "address"
    t.float    "lng"
    t.float    "lat"
    t.string   "phone"
    t.string   "email"
    t.string   "sponsor"
    t.boolean  "approved"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "games", :force => true do |t|
    t.string   "gamename"
    t.date     "gamedate"
    t.text     "players_result"
    t.string   "uploader"
    t.text     "detailgameinfo"
    t.string   "originalfileurl"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "uploadgame_id"
  end

  create_table "groupattendants", :force => true do |t|
    t.integer  "gamegroup_id"
    t.string   "regtype"
    t.string   "teamname"
    t.string   "phone"
    t.text     "attendee"
    t.integer  "registor_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "gsheet4games", :force => true do |t|
    t.string   "fileulr"
    t.integer  "holdgame_id"
    t.boolean  "in_use",      :default => false, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "holdgames", :force => true do |t|
    t.integer  "gameholder_id"
    t.string   "gamename"
    t.date     "startdate"
    t.date     "enddate"
    t.string   "gametype"
    t.text     "gamenote"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "address"
    t.string   "city"
    t.string   "county"
    t.string   "zipcode"
    t.string   "courtname"
    t.float    "lat"
    t.float    "lng"
    t.string   "url"
    t.boolean  "lttfgameflag",      :default => false
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "gameinfofile"
    t.string   "original_filename"
    t.string   "inputfileurl"
    t.integer  "gamedays"
    t.boolean  "cancel_flag",       :default => false
    t.text     "sponsors"
  end

  create_table "playerprofiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "initscore",           :default => 0
    t.integer  "curscore"
    t.integer  "totalwongames",       :default => 0
    t.integer  "totallosegames",      :default => 0
    t.date     "lastgamedate"
    t.string   "lastgamename"
    t.date     "lastscoreupdatedate"
    t.text     "gamehistory"
    t.string   "profileurl"
    t.string   "imageurl"
    t.string   "bio"
    t.string   "paddleholdtype"
    t.string   "paddlemodel"
    t.string   "forwardrubber"
    t.string   "backrubber"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "shopcarts", :force => true do |t|
    t.integer  "user_id"
    t.text     "address"
    t.integer  "X5L",          :default => 0, :null => false
    t.integer  "X4L",          :default => 0, :null => false
    t.integer  "X3L",          :default => 0, :null => false
    t.integer  "X2L",          :default => 0, :null => false
    t.integer  "L",            :default => 0, :null => false
    t.integer  "S",            :default => 0, :null => false
    t.integer  "XS",           :default => 0, :null => false
    t.text     "paymentinfo"
    t.boolean  "pay_check"
    t.boolean  "sent_flag"
    t.date     "sent_date"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "take_or_mail"
    t.integer  "XL",           :default => 0, :null => false
    t.integer  "M",            :default => 0, :null => false
    t.integer  "XXS",          :default => 0, :null => false
  end

  create_table "ttcourts", :force => true do |t|
    t.string   "placename"
    t.float    "lng"
    t.float    "lat"
    t.string   "city"
    t.string   "county"
    t.string   "zipcode"
    t.text     "address"
    t.text     "opentime"
    t.text     "facilities"
    t.text     "playfee"
    t.text     "contactinfo"
    t.text     "supplyinfo"
    t.text     "infosource"
    t.text     "infoURL"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "ttcourts", ["city"], :name => "index_ttcourts_on_city"
  add_index "ttcourts", ["county"], :name => "index_ttcourts_on_county"
  add_index "ttcourts", ["lat"], :name => "index_ttcourts_on_lat"
  add_index "ttcourts", ["lng"], :name => "index_ttcourts_on_lng"
  add_index "ttcourts", ["placename"], :name => "index_ttcourts_on_placename"
  add_index "ttcourts", ["zipcode"], :name => "index_ttcourts_on_zipcode"

  create_table "uploadgames", :force => true do |t|
    t.string   "gamename"
    t.date     "gamedate"
    t.text     "players_result"
    t.string   "uploader"
    t.text     "detailgameinfo"
    t.string   "originalfileurl"
    t.boolean  "publishedforchecking"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "suggestscore"
    t.string   "recorder"
    t.boolean  "scorecaculated"
    t.text     "adjustplayersinfo"
    t.integer  "holdgame_id"
  end

  create_table "users", :force => true do |t|
    t.string   "username",               :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "fbaccount",              :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "playerphoto"
    t.string   "phone"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "webpageviews", :force => true do |t|
    t.integer  "ttcourts_views", :limit => 8
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

end
