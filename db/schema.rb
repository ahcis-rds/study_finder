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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180126133905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "study_finder_condition_groups", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_conditions", force: :cascade do |t|
    t.string   "condition",  limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_disease_sites", force: :cascade do |t|
    t.string   "disease_site_name"
    t.integer  "group_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "study_finder_ds_trials", force: :cascade do |t|
    t.integer "disease_site_id"
    t.integer "trial_id"
  end

  create_table "study_finder_groups", force: :cascade do |t|
    t.string   "group_name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "children"
    t.boolean  "adults"
    t.boolean  "healthy_volunteers"
  end

  create_table "study_finder_locations", force: :cascade do |t|
    t.string   "location",   limit: 1000
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "zip",        limit: 255
    t.string   "country",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_parsers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "klass",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_sites", force: :cascade do |t|
    t.string   "site_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_finder_subgroups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_system_infos", force: :cascade do |t|
    t.string   "initials",                limit: 255
    t.string   "school_name",             limit: 255
    t.string   "system_name",             limit: 255
    t.string   "system_header",           limit: 255
    t.string   "system_description",      limit: 2000
    t.string   "search_term",             limit: 255
    t.string   "default_url",             limit: 255
    t.string   "default_email",           limit: 255
    t.string   "research_match_campaign", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_analytics_id",     limit: 255
    t.boolean  "display_all_locations"
    t.string   "contact_email_suffix",    limit: 255
    t.string   "secret_key",              limit: 255
    t.text     "researcher_description"
    t.boolean  "captcha",                              default: false, null: false
  end

  create_table "study_finder_trial_conditions", force: :cascade do |t|
    t.integer  "trial_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_trial_intervents", force: :cascade do |t|
    t.integer  "trial_id"
    t.string   "intervention_type", limit: 255
    t.string   "intervention",      limit: 255
    t.string   "description",       limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_trial_keywords", force: :cascade do |t|
    t.integer  "trial_id"
    t.string   "keyword",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_trial_locations", force: :cascade do |t|
    t.integer  "trial_id"
    t.integer  "location_id"
    t.string   "status",                 limit: 255
    t.string   "last_name",              limit: 255
    t.string   "phone",                  limit: 255
    t.string   "email",                  limit: 255
    t.string   "backup_last_name",       limit: 255
    t.string   "backup_phone",           limit: 255
    t.string   "backup_email",           limit: 255
    t.string   "investigator_last_name", limit: 255
    t.string   "investigator_role",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_trial_mesh_terms", force: :cascade do |t|
    t.integer  "trial_id"
    t.string   "mesh_term_type", limit: 255
    t.string   "mesh_term",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_trial_sites", force: :cascade do |t|
    t.integer  "trial_id"
    t.integer  "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_finder_trials", force: :cascade do |t|
    t.string   "system_id",                   limit: 255
    t.string   "brief_title",                 limit: 1000
    t.string   "official_title",              limit: 4000
    t.string   "acronym",                     limit: 255
    t.string   "phase",                       limit: 255
    t.string   "overall_status",              limit: 255
    t.string   "source",                      limit: 1000
    t.string   "verification_date",           limit: 255
    t.text     "brief_summary"
    t.text     "detailed_description"
    t.string   "gender",                      limit: 255
    t.string   "minimum_age",                 limit: 255
    t.string   "maximum_age",                 limit: 255
    t.boolean  "healthy_volunteers"
    t.string   "simple_description",          limit: 4000
    t.string   "contact_override",            limit: 255
    t.boolean  "visible"
    t.boolean  "recruiting"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_override_first_name", limit: 255
    t.string   "contact_override_last_name",  limit: 255
    t.integer  "parser_id"
    t.string   "official_last_name",          limit: 255
    t.string   "official_first_name",         limit: 255
    t.string   "official_role",               limit: 255
    t.string   "official_affiliation",        limit: 255
    t.string   "contact_last_name",           limit: 255
    t.string   "contact_first_name",          limit: 255
    t.string   "contact_phone",               limit: 255
    t.string   "contact_email",               limit: 255
    t.string   "contact_backup_last_name",    limit: 255
    t.string   "contact_backup_first_name",   limit: 255
    t.string   "contact_backup_phone",        limit: 255
    t.string   "contact_backup_email",        limit: 255
    t.text     "eligibility_criteria"
    t.string   "recruitment_url",             limit: 255
    t.string   "min_age_unit",                limit: 255
    t.string   "max_age_unit",                limit: 255
    t.string   "lastchanged_date",            limit: 255
    t.string   "firstreceived_date",          limit: 255
    t.boolean  "reviewed",                                 default: false
    t.integer  "featured",                                 default: 0
    t.string   "irb_number"
    t.string   "cancer_yn"
    t.string   "pi_name"
    t.string   "pi_id"
  end

  create_table "study_finder_updaters", force: :cascade do |t|
    t.integer  "parser_id"
    t.integer  "num_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_finder_users", force: :cascade do |t|
    t.string   "email",           limit: 255, default: "", null: false
    t.integer  "sign_in_count",               default: 0,  null: false
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip", limit: 255
    t.string   "internet_id",     limit: 255, default: "", null: false
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.string   "phone",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "study_finder_users", ["email"], name: "index_study_finder_users_on_email", unique: true, using: :btree
  add_index "study_finder_users", ["internet_id"], name: "index_study_finder_users_on_internet_id", unique: true, using: :btree

end
