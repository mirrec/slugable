# 1.0.0 (November 22, 2015)
## added
* add ability to pass cache storage to tree structure `tree_cache_storage`
* add ability to set default `formatter` and `tree_cache_storage` in config
```ruby
Slugable.configure do |config|
  config.formatter          = MyFormatter
  config.tree_cache_storage = Rails.cache
end
```
* introduce slug builder
* add ability to pass own slug builder
```ruby
# you own to slug builder
class StupidToSlug
  def to_slug(record)
    "to_slug_#{record.id}"
  end

  def to_slug_was(record)
    "to_slug_was_#{record.id}"
  end

  def to_slug_will(record)
    "to_slug_will_#{record.id}"
  end
end

# model
class News < ActiveRecord::Base
  # columns: :id, :name, :slug

  has_slug to_slug_builder: StupidToSlug.new
end
```
* travis ci for running tests
  * tests run against ruby `1.9.3`, `2.2.2` and `activerecord` from >= `3.2` <= `4.2`
* test coverage
* code climate
## changed
* big internal refactoring
* `formatter` param now expect callable object
* `cache_tree` option has been change to `tree_cache_storage` and expect object that can store cache (e.g. Rails.cache), it is `nil` by default
* ruby version to `2.2.2`
* hash to new syntax
* all spec uses expect syntax
* `to_slug` method for tree structure now returns array all the time
## fixed
* several bugs with caching

# 0.0.4 (May 30, 2013)
## fixed
* `to_slug` method not skip nil in path

# 0.0.3 (March 04, 2013)
## added
* config for allowing or disabling caching
* `to_slug_was` for getting old values of object `to_slug`
* `to_slug_will` for getting future values of object `to_slug`
* options for specifying string formatting method
* options for enabling or disabling cacing slugs for tree

# 0.0.3.beta (December 27, 2012)
## changed
* skip cache in tree
## fixed
* tests and schema for appropriate testing

# 0.0.2 (December 5, 2012)
## fixed
* fill in slug from name parameter if slug.parameterize is blank

# 0.0.1 (October 11, 2012)
## added
* init version from real project
* support for storing seo friendly url
* caching slug for ancestry models
* all covered with tests