require 'spec_helper'
require 'support/hash_cache_storage'
ActiveRecord::Base.send :extend, Slugable::HasSlug

hash_cache_storage = HashCacheStorage.new

Slugable.configure do |config|
  config.tree_cache_storage = hash_cache_storage
end

class Item < ActiveRecord::Base
  has_slug
end

class Page < ActiveRecord::Base
  has_slug :from => :title, :to => :seo_url
end

class Category < ActiveRecord::Base
  has_ancestry
  has_slug :tree_cache_storage => nil
end

class TreeItem < ActiveRecord::Base
  has_ancestry
  has_slug :tree_cache_storage => Slugable.configuration.tree_cache_storage
end

class Product < ActiveRecord::Base
  has_slug :formatter => lambda { |string| 'hello-all-the-time' }
end

describe Slugable::HasSlug do
  before(:each) do
    hash_cache_storage.clear
  end

  context 'default options' do
    it 'should create fill_slug_from_name_to_slug' do
      Item.new.should respond_to :prepare_slug_in_slug
    end

    it 'should fill in slug parameter from attribute name and parametrize it' do
      name = 'my name is'
      name.should_receive(:parameterize).and_return('my-name-is')

      item = Item.create!(:name => name)
      item.slug.should eq 'my-name-is'
    end

    it 'should fill in slug from attribute name if parameterize version of slug is blank' do
      item = Item.create!(:name => 'my name is', :slug => '/')
      item.slug.should eq 'my-name-is'
    end

    it 'should only parametrize slug attribute if slug is present' do
      item = Item.create!(:name => 'my name is', :slug => 'my url')
      item.slug.should eq 'my-url'
    end
  end

  context 'given options' do
    it 'should create fill_slug_from_title_to_seo_url' do
      Page.new.should respond_to :prepare_slug_in_seo_url
    end

    it 'should fill in slug parameter from attribute title and parametrize it' do
      page = Page.create!(:title => 'my name is')
      page.seo_url.should eq 'my-name-is'
    end

    it 'should fill in slug parameter from attribute title if parameterize version of slug is blank' do
      page = Page.create!(:title => 'my name is', :seo_url => '/')
      page.seo_url.should eq 'my-name-is'
    end

    it 'should only parametrize slug attribute if slug is present' do
      page = Page.create!(:title => 'my name is', :seo_url => 'my url')
      page.seo_url.should eq 'my-url'
    end

    it 'should be able to change parameterize method' do
      product = Product.create!(:name => 'my name is', :slug => 'product')
      product.slug.should eq 'hello-all-the-time'
    end
  end

  describe 'to_slug' do
    context 'default options' do
      it 'should define method to_seo_url' do
        Item.new.should respond_to :to_slug
      end

      it 'should return slug in string' do
        item = Item.create!(:name => 'my name is', :slug => 'my-url')
        item.to_slug.should eq 'my-url'
      end
    end

    context 'given options' do
      it 'should define method to_seo_url' do
        Page.new.should respond_to :to_seo_url
      end

      it 'should return slug in string' do
        page = Page.create!(:title => 'my name is', :seo_url => 'my-url')
        page.to_seo_url.should eq 'my-url'
      end
    end

    context 'ancestry model' do
      it 'should return array of slugs' do
        root = Category.create!(:name => 'root', :slug => 'root')
        child = Category.new(:name => 'child', :slug => 'child')
        child.parent = root
        child.save!

        child.to_slug.should eq ['root', 'child']
      end

      it 'should skip nil values from slug path' do
        root = Category.create!(:name => 'root', :slug => 'root')
        child = Category.new(:name => 'child', :slug => 'child')
        child.parent = root
        child.save!

        Category.update_all({:slug => nil}, {:id => root.id})
        hash_cache_storage.clear

        child.to_slug.should eq ['child']
      end
    end
  end

  describe 'to_slug_was' do
    context 'default options' do
      it 'should define method to_slug_was' do
        Item.new.should respond_to :to_slug_was
      end

      it 'should return old slug in string' do
        item = Item.create!(:name => 'my name is', :slug => 'my-url')
        item.slug = 'new-slug'
        item.to_slug_was.should eq 'my-url'
      end
    end

    context 'given options' do
      it 'should define method to_seo_url_was' do
        Page.new.should respond_to :to_seo_url_was
      end

      it 'should return future slug in string' do
        page = Page.create!(:title => 'my name is', :seo_url => 'my-url')
        page.seo_url = 'hello-world'
        page.to_seo_url_was.should eq 'my-url'
      end
    end

    context 'ancestry model' do
      it 'should return array of old slugs' do
        root = Category.create!(:name => 'root', :slug => 'root')
        child = Category.new(:name => 'child', :slug => 'child')
        child.save!

        child.parent = root
        child.slug = 'moved'
        child.to_slug_was.should eq ['child']
      end
    end
  end

  describe 'to_slug_will' do
    context 'default options' do
      it 'should define method to_slug_will' do
        Item.new.should respond_to :to_slug_will
      end

      it 'should return future slug in string' do
        item = Item.create!(:name => 'my name is', :slug => 'my-url')
        item.slug = 'new slug'
        item.to_slug_will.should eq 'new-slug'
      end
    end

    context 'given options' do
      it 'should define method to_seo_url_will' do
        Page.new.should respond_to :to_seo_url_will
      end

      it 'should return slug in string' do
        page = Page.create!(:title => 'my name is', :seo_url => 'my-url')
        page.seo_url = 'hello world'
        page.to_seo_url_will.should eq 'hello-world'
      end
    end

    context 'ancestry model' do
      it 'should return array of slugs' do
        root = Category.create!(:name => 'root', :slug => 'root')
        child = Category.new(:name => 'child', :slug => 'child')
        child.save!

        child.parent = root
        child.slug = 'move d'
        child.to_slug_will.should eq ['root', 'move-d']
      end
    end
  end
end
