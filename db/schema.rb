ActiveRecord::Schema.define do
  create_table "flat_items", force: true do |t|
    t.string "name"
    t.string "title"
    t.string "slug"
    t.string "seo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flat_pages", force: true do |t|
    t.string "title"
    t.string "seo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tree_categories", force: true do |t|
    t.string "name"
    t.string "ancestry"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flat_products", force: true do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tree_items", force: true do |t|
    t.string "name"
    t.string "ancestry"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
