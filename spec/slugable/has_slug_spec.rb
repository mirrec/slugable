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
        expect(record).to respond_to :slug_builder_for_slug
        expect(record).to respond_to :prepare_slug_in_slug
        expect(record).to respond_to :to_slug
        expect(record).to respond_to :to_slug_was
        expect(record).to respond_to :to_slug_will
      end
    end

    context 'option with cache' do
      it 'creates method that updates cache' do
        record = TreeItem.new
        expect(record).to respond_to :update_my_slug_cache
      end
    end
  end

  context 'callbacks' do
    context 'default options' do
      it 'fills in slug parameter from attribute apply a parameterize format to it' do
        name = 'my name is'

        item = FlatItem.create!(name: name)
        expect(item.slug).to eq 'my-name-is'
      end

      it 'fills in slug from attribute name if parameterize version of slug is blank' do
        item = FlatItem.create!(name: 'my name is', slug: '')
        expect(item.slug).to eq 'my-name-is'
      end

      it 'does not change slug attribute if slug is present' do
        item = FlatItem.create!(name: 'my name is', slug: 'my url')
        expect(item.slug).to eq 'my-url'
      end
    end

    context 'given options' do
      it 'creates fill_slug_from_title_to_seo_url' do
        expect(FlatPage.new).to respond_to :prepare_slug_in_seo_url
      end

      it 'fills in slug parameter from attribute title and parametrize it' do
        page = FlatPage.create!(title: 'my name is')
        expect(page.seo_url).to eq 'my-name-is'
      end

      it 'fills in slug parameter and use custom formatter' do
        product = FlatProduct.create!(name: 'my name is', slug: 'product')
        expect(product.slug).to eq 'hello-all-the-time'
      end
    end
  end

  describe '#to_slug' do
    context 'default options' do
      it 'defines to_slug method' do
        expect(FlatItem.new).to respond_to :to_slug
      end

      it 'returns slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        expect(item.to_slug).to eq 'my-url'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url' do
        expect(FlatPage.new).to respond_to :to_seo_url
      end

      it 'returns slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        expect(page.to_seo_url).to eq 'my-url'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        expect(news.to_slug).to eq "to_slug_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.parent = root
        child.save!

        expect(child.to_slug).to eq ['root', 'child']
      end

      it 'skips nil values from slug path' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.parent = root
        child.save!

        TreeCategory.update_all({slug: nil}, {id: root.id})
        hash_cache_storage.clear

        expect(child.to_slug).to eq ['child']
      end

      it 'returns correct results also with caching support' do
        child = TreeItem.create!(slug: 'child', parent: TreeItem.create!(slug: 'root'))
        expect(child.to_slug).to eq ['root', 'child']
        expect(child.to_slug).to eq ['root', 'child']
      end
    end
  end

  describe '#to_slug_was' do
    context 'default options' do
      it 'defines method to_slug_was' do
        expect(FlatItem.new).to respond_to :to_slug_was
      end

      it 'returns old slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        item.slug = 'new-slug'
        expect(item.to_slug_was).to eq 'my-url'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url_was' do
        expect(FlatPage.new).to respond_to :to_seo_url_was
      end

      it 'returns future slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        page.seo_url = 'hello-world'
        expect(page.to_seo_url_was).to eq 'my-url'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        expect(news.to_slug_was).to eq "to_slug_was_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of old slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.save!

        child.parent = root
        child.slug = 'moved'
        expect(child.to_slug_was).to eq ['child']
      end
    end
  end

  describe '#to_slug_will' do
    context 'default options' do
      it 'defines method to_slug_will' do
        expect(FlatItem.new).to respond_to :to_slug_will
      end

      it 'returns future slug in string' do
        item = FlatItem.create!(name: 'my name is', slug: 'my-url')
        item.slug = 'new slug'
        expect(item.to_slug_will).to eq 'new-slug'
      end
    end

    context 'given options' do
      it 'defines method to_seo_url_will' do
        expect(FlatPage.new).to respond_to :to_seo_url_will
      end

      it 'returns slug in string' do
        page = FlatPage.create!(title: 'my name is', seo_url: 'my-url')
        page.seo_url = 'hello world'
        expect(page.to_seo_url_will).to eq 'hello-world'
      end

      it 'returns result from custom to_slug_builder' do
        news = FlatNews.create!(name: 'news')
        expect(news.to_slug_will).to eq "to_slug_will_#{news.id}"
      end
    end

    context 'tree models' do
      it 'returns array of slugs' do
        root = TreeCategory.create!(name: 'root', slug: 'root')
        child = TreeCategory.new(name: 'child', slug: 'child')
        child.save!

        child.parent = root
        child.slug = 'move d'
        expect(child.to_slug_will).to eq ['root', 'move-d']
      end
    end
  end
end
