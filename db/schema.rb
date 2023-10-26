# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_25_203753) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "approvals", force: :cascade do |t|
    t.integer "trial_id"
    t.integer "user_id"
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "showcase_items", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "caption"
    t.string "url"
    t.boolean "active", default: false
    t.integer "sort_order"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "study_finder_condition_groups", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "condition_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_conditions", id: :serial, force: :cascade do |t|
    t.string "condition", limit: 1000
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "condition_groups_count"
  end

  create_table "study_finder_disease_sites", id: :serial, force: :cascade do |t|
    t.string "disease_site_name"
    t.integer "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "study_finder_ds_trials", id: :serial, force: :cascade do |t|
    t.integer "disease_site_id"
    t.integer "trial_id"
  end

  create_table "study_finder_groups", id: :serial, force: :cascade do |t|
    t.string "group_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "children"
    t.boolean "adults"
    t.boolean "healthy_volunteers"
  end

  create_table "study_finder_locations", id: :serial, force: :cascade do |t|
    t.string "location", limit: 1000
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_parsers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "klass"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_sites", id: :serial, force: :cascade do |t|
    t.string "site_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "study_finder_subgroups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "group_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_system_infos", id: :serial, force: :cascade do |t|
    t.string "initials"
    t.string "school_name"
    t.string "system_name"
    t.string "system_header"
    t.string "system_description", limit: 2000
    t.string "search_term"
    t.string "default_url"
    t.string "default_email"
    t.string "research_match_campaign"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "secret_key"
    t.string "google_analytics_id"
    t.boolean "display_all_locations"
    t.string "contact_email_suffix"
    t.text "researcher_description"
    t.boolean "captcha", default: false, null: false
    t.boolean "display_keywords", default: true
    t.boolean "display_groups_page", default: true, null: false
    t.boolean "display_study_show_page", default: false, null: false
    t.boolean "enable_showcase", default: false, null: false
    t.boolean "show_showcase_indicators", default: true, null: false
    t.boolean "show_showcase_controls", default: false, null: false
    t.text "faq_description"
    t.boolean "trial_approval", default: false, null: false
    t.boolean "alert_on_empty_system_id", default: false, null: false
    t.string "study_contact_bcc"
    t.boolean "protect_simple_description", default: false, null: false
    t.boolean "healthy_volunteers_filter", default: true, null: false
    t.boolean "gender_filter", default: true, null: false
    t.integer "google_analytics_version"
  end

  create_table "study_finder_trial_conditions", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.integer "condition_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["condition_id"], name: "condition_idx"
  end

  create_table "study_finder_trial_intervents", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.string "intervention_type"
    t.string "intervention"
    t.string "description", limit: 4000
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_trial_keywords", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.string "keyword"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_trial_locations", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.integer "location_id"
    t.string "status"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.string "backup_last_name"
    t.string "backup_phone"
    t.string "backup_email"
    t.string "investigator_last_name"
    t.string "investigator_role"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["location_id"], name: "index_study_finder_trial_locations_on_location_id"
    t.index ["trial_id"], name: "index_study_finder_trial_locations_on_trial_id"
  end

  create_table "study_finder_trial_mesh_terms", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.string "mesh_term_type"
    t.string "mesh_term"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_trial_sites", id: :serial, force: :cascade do |t|
    t.integer "trial_id"
    t.integer "site_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "study_finder_trials", id: :serial, force: :cascade do |t|
    t.string "system_id"
    t.string "brief_title", limit: 1000
    t.string "official_title", limit: 4000
    t.string "acronym"
    t.string "phase"
    t.string "overall_status"
    t.string "source", limit: 1000
    t.string "verification_date"
    t.text "brief_summary"
    t.text "detailed_description"
    t.string "gender"
    t.string "minimum_age"
    t.string "maximum_age"
    t.boolean "healthy_volunteers"
    t.string "simple_description", limit: 4000
    t.string "contact_override"
    t.boolean "visible"
    t.boolean "recruiting"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "contact_override_first_name"
    t.string "contact_override_last_name"
    t.integer "parser_id"
    t.string "official_last_name"
    t.string "official_first_name"
    t.string "official_role"
    t.string "official_affiliation"
    t.string "contact_last_name"
    t.string "contact_first_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "contact_backup_last_name"
    t.string "contact_backup_first_name"
    t.string "contact_backup_phone"
    t.string "contact_backup_email"
    t.text "eligibility_criteria"
    t.string "recruitment_url"
    t.string "min_age_unit"
    t.string "max_age_unit"
    t.string "lastchanged_date"
    t.string "firstreceived_date"
    t.boolean "reviewed"
    t.integer "featured", default: 0
    t.string "irb_number"
    t.string "cancer_yn"
    t.string "pi_name"
    t.string "pi_id"
    t.string "contact_url"
    t.string "contact_url_override"
    t.boolean "healthy_volunteers_imported"
    t.boolean "healthy_volunteers_override"
    t.date "added_on"
    t.boolean "display_simple_description", default: true, null: false
    t.boolean "rare_disease_flag"
    t.string "nct_id"
    t.boolean "approved", default: false, null: false
    t.string "annotations_flag"
    t.string "protocol_type"
    t.string "simple_description_override"
    t.index ["approved"], name: "index_study_finder_trials_on_approved"
    t.index ["recruiting"], name: "index_study_finder_trials_on_recruiting"
    t.index ["reviewed"], name: "index_study_finder_trials_on_reviewed"
    t.index ["visible"], name: "index_study_finder_trials_on_visible"
  end

  create_table "study_finder_updaters", id: :serial, force: :cascade do |t|
    t.integer "parser_id"
    t.integer "num_updated"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "study_finder_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "internet_id", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_study_finder_users_on_email", unique: true
    t.index ["internet_id"], name: "index_study_finder_users_on_internet_id", unique: true
  end

  create_table "trial_attribute_settings", force: :cascade do |t|
    t.integer "system_info_id"
    t.string "attribute_name"
    t.string "attribute_key"
    t.string "attribute_label"
    t.boolean "display_label_on_list", default: true
    t.boolean "display_on_list", default: true
    t.boolean "display_if_null_on_list", default: true
    t.boolean "display_label_on_show", default: true
    t.boolean "display_on_show", default: true
    t.boolean "display_if_null_on_show", default: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
