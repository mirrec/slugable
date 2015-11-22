require 'spec_helper'
require 'support/hash_cache_storage'

hash_cache_storage = HashCacheStorage.new

Slugable.configure do |config|
  config.tree_cache_storage = hash_cache_storage
end

require 'support/set_up_models'

describe Slugable::HasSlug do
  before(:each) do
    hash_cache_storage.clear
  end

  context 'method definitions' do
    context 'default options' do
      it 'creates all needed methods for slug' do
        record = FlatItem.new
        record.should respond_to :slug_builder_for_slug
        record.should respond_to :prepare_slug_in_slug
        record.should respond_to :to_slug
        record.should respond_to :to_slug_was
        record.should respond_to :to_slug_will
      end
    end

    context 'option with cache' do
      it 'creates method that updates cache' do
        record = TreeItem.new
        record.should respond_to :update_my_slug_cache
      end
    end
  end

  context 'callbacks' do
    context 'default options' do
      it 'fills in slug parameter from attribute apply a parameterize format to it' do
        name = 'my name is'

        item = FlatItem.create!(name: name)
        item.slug.should eq 'my-name-is'
      end

      it 'fills in slug from attribute name if parameterize version of slug is blank' do
        item = FlatItem.create!(name: 'my name is', slug: '')
        item.slug.should eq 'my-name-is'
      end

      it 'does not change slug attribute if slug is present' do
        item = FlatItem.create!(name: 'my name is', slug: 'my url')
        item.slug.should eq 'my-url'
      end
    end

    context 'given options' do
      it 'creates fill_slug_from_title_to_seo_url' do
        FlatPage.new.should respond_to :prepare_slug_in_seo_url
      end

      it 'fills in slug parameter from attribute title and parametrize it' do
        page = FlatPage.create!(title: 'my name is')
        page.seo_url.should eq 'my-name-is'
      end

      it 'fills in slug parameter and use custom formatter' do
        product = FlatProduct.create!(name: 'my name is', slug: 'product')
        product.slug.should eq 'hello-all-the-time'
      end
    end
  end

  describe '#to_slug' do
    context 'default options' do
      it 'defines to_slug method' do
        FlatItem.new.should respond_to :to_slug
      end

      it 'returns slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        item.to_slug.should eq 'my-url'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url' do
        FlatPage.new.should respond_to :to_seo_url
      end

      it 'returns slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        page.to_seo_url.should eq 'my-url'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        news.to_slug.should eq "to_slug_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.parent = root
        child.save!

        child.to_slug.should eq ['root', 'child']
      end

      it 'skips nil values from slug path' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.parent = root
        child.save!

        TreeCategory.update_all({slug: nil}, {id: root.id})
        hash_cache_storage.clear

        child.to_slug.should eq ['child']
      end

      it 'returns correct results also with caching support' do
        child = TreeItem.create!(slug: 'child', parent: TreeItem.create!(slug: 'root'))
        child.to_slug.should eq ['root', 'child']
        child.to_slug.should eq ['root', 'child']
      end
    end
  end

  describe '#to_slug_was' do
    context 'default options' do
      it 'defines method to_slug_was' do
        FlatItem.new.should respond_to :to_slug_was
      end

      it 'returns old slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        item.slug = 'new-slug'
        item.to_slug_was.should eq 'my-url'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url_was' do
        FlatPage.new.should respond_to :to_seo_url_was
      end

      it 'returns future slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        page.seo_url = 'hello-world'
        page.to_seo_url_was.should eq 'my-url'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        news.to_slug_was.should eq "to_slug_was_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of old slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.save!

        child.parent = root
        child.slug = 'moved'
        child.to_slug_was.should eq ['child']
      end
    end
  end

  describe '#to_slug_will' do
    context 'default options' do
      it 'defines method to_slug_will' do
        FlatItem.new.should respond_to :to_slug_will
      end

      it 'returns future slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        item.slug = 'new slug'
        item.to_slug_will.should eq 'new-slug'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url_will' do
        FlatPage.new.should respond_to :to_seo_url_will
      end

      it 'returns slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        page.seo_url = 'hello world'
        page.to_seo_url_will.should eq 'hello-world'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        news.to_slug_will.should eq "to_slug_will_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.save!

        child.parent = root
        child.slug = 'move d'
        child.to_slug_will.should eq ['root', 'move-d']
      end
    end
  end
end
