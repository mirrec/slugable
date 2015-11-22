class FlatItem < ActiveRecord::Base
  has_slug
end

class FlatPage < ActiveRecord::Base
  has_slug from: :title, to: :seo_url
end

class TreeCategory < ActiveRecord::Base
  has_ancestry
  has_slug tree_cache_storage: nil
end

class TreeItem < ActiveRecord::Base
  has_ancestry
  has_slug tree_cache_storage: Slugable.configuration.tree_cache_storage
end

class FlatProduct < ActiveRecord::Base
  has_slug formatter: lambda { |string| 'hello-all-the-time' }
end
