ActiveRecord::Schema.define do
  create_table "items", :force => true do |t|
    t.string "name"
    t.string "title"
    t.string "slug"
    t.string "seo_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string "title"
    t.string "seo_path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.string "name"
    t.string "ancestry"
    t.string "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
end
