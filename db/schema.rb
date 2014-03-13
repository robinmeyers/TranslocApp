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

ActiveRecord::Schema.define(version: 20140313015854) do

  create_table "assemblies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chromosomes", force: true do |t|
    t.string   "name"
    t.integer  "assembly_id"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cytobands", force: true do |t|
    t.string   "name"
    t.integer  "assembly_id"
    t.string   "chrom"
    t.integer  "start"
    t.integer  "end"
    t.string   "stain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "junctions", force: true do |t|
    t.string   "qname"
    t.integer  "qstart"
    t.integer  "qend"
    t.string   "rname"
    t.integer  "rstart"
    t.integer  "rend"
    t.string   "strand"
    t.text     "seq"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "junction"
    t.integer  "library_id"
    t.integer  "b_qstart"
    t.integer  "b_qend"
    t.string   "b_rname"
    t.integer  "b_rstart"
    t.integer  "b_rend"
    t.string   "b_strand"
    t.integer  "qlen"
    t.string   "j_seq"
  end

  add_index "junctions", ["library_id", "rname", "junction"], name: "index_junctions_on_library_id_and_rname_and_junction"

  create_table "libraries", force: true do |t|
    t.string   "name"
    t.integer  "researcher_id"
    t.integer  "sequencing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "assembly"
    t.string   "mid"
    t.string   "primer"
    t.text     "breakseq"
    t.string   "adapter"
    t.string   "chr"
    t.integer  "bstart"
    t.integer  "bend"
    t.text     "description"
    t.string   "cutter"
    t.string   "strand"
    t.integer  "breaksite"
  end

  add_index "libraries", ["researcher_id", "sequencing_id"], name: "index_libraries_on_researcher_id_and_sequencing_id"

  create_table "researchers", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "researchers", ["email"], name: "index_researchers_on_email", unique: true
  add_index "researchers", ["remember_token"], name: "index_researchers_on_remember_token"

  create_table "sequencings", force: true do |t|
    t.string   "run"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "completed_on"
  end

  add_index "sequencings", ["run", "completed_on"], name: "index_sequencings_on_run_and_completed_on"

end
