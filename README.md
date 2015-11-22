# Slugable

[![Build Status](https://travis-ci.org/mirrec/slugable.svg?branch=master)](https://travis-ci.org/mirrec/slugable)
[![Gem Version](https://badge.fury.io/rb/slugable.svg)](https://badge.fury.io/rb/slugable)
[![Code Climate](https://codeclimate.com/github/mirrec/slugable/badges/gpa.svg)](https://codeclimate.com/github/mirrec/slugable)
[![Test Coverage](https://codeclimate.com/github/mirrec/slugable/badges/coverage.svg)](https://codeclimate.com/github/mirrec/slugable/coverage)

* adds support for creating seo friendly url to your active record models and simplifies generating url

```ruby
# model
class Article < ActiveRecord::Base
  # has columns: id, name, slug
  has_slug
end

# creating new
item = Article.create!(name: 'First article')
item.slug # => 'first-article'
item.to_slug # => 'first-article'

# routes to the article
get "articles/:slug" => "articles#show", as: :article

# view
link_to 'My first article', article_path(item.to_slug) # => '/articles/first-article'
```

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

* default configuration converts name column to slug column

```ruby
class Item < ActiveRecord::Base
  # columns :name, :slug

  has_slug # default from: :name, to: :slug
end

# then in code
item = Item.create!(name: "my name is")
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
  # has columns: :id, :title, :seo_url

  has_slug from: :title, to: :seo_url, formatter: lambda { |string| string.downcase }
end

# then in code
page = Page.create!(title: "NAME")
page.seo_url # => "name"
page.to_seo_url # => "name"
```

if model is a tree structure and you use [ancestry gem](https://github.com/stefankroes/ancestry),
tree like structure will be generated

```ruby
class Category < ActiveRecord::Base
  # has columns: :id, :name, :slug

  has_ancestry
  has_slug
end

# then in code
root = Category.create!(name: "root", slug: "root")
root.slug # => "root"
root.to_slug # => ["root"]

child = Category.new(name: "child", slug: "child")
child.parent = root
child.save!

child.slug # => "child"
child.to_slug # => ["root", "child"]

branch = Category.create!(name: "branch", slug: "branch")
child.parent = branch
child.slug = "renamed"

child.to_slug_was # => ["root", "child"]
child.to_slug_will # => ["branch", "renamed"]

child.to_slug # => ["root", "child"]
child.save!
child.to_slug # => ["branch", "renamed"]
```

* You can cache slug for tree structure if you want to optimize performance, all you need is to pass cache storage object

```ruby
class Category < ActiveRecord::Base
  # has columns: :id, :name, :slug

  has_ancestry
  has_slug tree_cache_storage: Rails.cache
end
```

## Configuration

You can set up default formatter and default tree_cache_storage in you initializer.

```ruby
class MyFormatter
  def format(string)
    string.my_own_parameterize
  end
end

Slugable.configure do |config|
  config.formatter          = MyFormatter
  config.tree_cache_storage = Rails.cache
end
```

`to_slug`, `to_slug_was` and `to_slug_will` methods are implemented by to_slug_builder. You can implement you own one and pass as configuration

```ruby
# you own to slug builder
class SimpleToSlug
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

  has_slug to_slug_builder: SimpleToSlug.new
end

# code
news = News.create!(name: 'whatever')
news.to_slug.should eq "to_slug_#{news.id}"
news.to_slug_was.should eq "to_slug_was_#{news.id}"
news.to_slug_will.should eq "to_slug_will_#{news.id}"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
