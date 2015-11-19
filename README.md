# Slugable

[![Build Status](https://travis-ci.org/mirrec/slugable.svg?branch=master)](https://travis-ci.org/mirrec/slugable)
[![Gem Version](https://badge.fury.io/rb/slugable.svg)](https://badge.fury.io/rb/slugable)

* adds support for seo friendly url
* one helper method has_slug
* support for ancestry models 'https://github.com/stefankroes/ancestry'
* be default cache ancestry models url, can be changed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slugable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slugable

## Usage

in model use method has_slug

```ruby
class Item < ActiveRecord::Base
  attr_accessor :name, :slug

  has_slug # default :from => :name, :to => :slug, :formatter => :parameterize, :cache_tree => true
end

# then in code
item = Item.create!(:name => "my name is")
item.slug # => "my-name-is"

item.to_slug # => "my-name-is"

item.slug = "new-slug

item.to_slug_was  # => "my-name-is"
item.to_slug_will # => "new-slug"
item.to_slug      # => "new-slug"
```

you can override defaults by passing hash

```ruby
class Page < ActiveRecord::Base
  attr_accessor :title, :seo_url

  has_slug :from => :title, :to => :seo_url, :formatter => :my_style
end

class String
  def my_style
    self.parameterize
  end
end

# then in code
page = Page.create!(:title => "my name is", :seo_url => "my url")
page.seo_url # => "my-url"
page.to_seo_url # => "my-url"
```

if you have model with ancestry gem 'https://github.com/stefankroes/ancestry'

```ruby
class Category < ActiveRecord::Base
  attr_accessor :name, :slug

  has_ancestry
  has_slug
end

# then in code
root = Category.create!(:name => "root", :slug => "root")
root.slug # => "root"
root.to_slug # => ["root"]

child = Category.new(:name => "child", :slug => "child")
child.parent = root
child.save!

child.slug # => "child"
child.to_slug # => ["root", "child"]

branch = Category.create!(:name => "branch", :slug => "branch")
child.parent = branch
child.slug = "renamed"

child.to_slug_was # => ["root", "child"]
child.to_slug_will # => ["branch", "renamed"]

child.to_slug # => ["root", "child"]
child.save!
child.to_slug # => ["branch", "renamed"]
```

## configuration

  By default all ancestry structure are cached to prevent useless calls to fetch same record from database just for slug values.
  You can pass :cache_tree option to disable it like this.

```ruby
class Category < ActiveRecord::Base
  attr_accessor :name, :slug

  has_ancestry
  has_slug :cache_tree => false
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
