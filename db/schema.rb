# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_28_015924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.bigint "teacher_id", null: false
    t.datetime "time_slot", null: false
    t.bigint "language_id"
    t.bigint "student_id"
    t.string "zoom_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "feedback"
    t.text "content"
    t.index ["language_id"], name: "index_courses_on_language_id"
    t.index ["student_id"], name: "index_courses_on_student_id"
    t.index ["teacher_id", "time_slot"], name: "index_courses_on_teacher_id_and_time_slot", unique: true
    t.index ["teacher_id"], name: "index_courses_on_teacher_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code", limit: 2
    t.string "name"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "teached_languages", force: :cascade do |t|
    t.bigint "teacher_id"
    t.bigint "language_id"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["language_id"], name: "index_teached_languages_on_language_id"
    t.index ["teacher_id", "language_id"], name: "index_teached_languages_on_teacher_id_and_language_id", unique: true
    t.index ["teacher_id"], name: "index_teached_languages_on_teacher_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 20, null: false
    t.string "image"
    t.string "presentation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_teachers_on_name", unique: true
    t.index ["user_id"], name: "index_teachers_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expiration"
    t.integer "initial_count", default: 0, null: false
    t.integer "remaining", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username", limit: 20, null: false
    t.string "stripe_user_id"
    t.string "stripe_plan_id"
    t.string "stripe_subscription_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "courses", "languages"
  add_foreign_key "courses", "teachers"
  add_foreign_key "courses", "users", column: "student_id"
  add_foreign_key "teached_languages", "languages"
  add_foreign_key "teached_languages", "teachers"
  add_foreign_key "tickets", "users"
end
