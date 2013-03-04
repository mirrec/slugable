require "spec_helper"

ActiveRecord::Base.send :extend, Slugable::HasSlug

class Item < ActiveRecord::Base
  attr_accessible :name, :slug

  has_slug
end

class Page < ActiveRecord::Base
  attr_accessible :title, :seo_url

  has_slug :from => :title, :to => :seo_url
end

class Category < ActiveRecord::Base
  attr_accessible :name, :slug

  has_ancestry
  has_slug
end

class TreeItem < ActiveRecord::Base
  attr_accessible :name, :slug

  has_ancestry
  has_slug :cache_tree => false
end

class Product < ActiveRecord::Base
  attr_accessible :name, :slug

  has_slug :formatter => :my_formatter
end


describe Slugable::HasSlug do
  before(:each) do
    Category.clear_cached_slugs
  end

  context "default options" do
    it "should create fill_slug_from_name_to_slug" do
      Item.new.should respond_to :fill_slug_from_name_to_slug
    end

    it "should create format_slug_from_name_to_slug" do
      Item.new.should respond_to :format_slug_from_name_to_slug
    end

    it "should fill in slug parameter from attribute name and parametrize it" do
      name = "my name is"
      name.should_receive(:parameterize).and_return("my-name-is")

      item = Item.create!(:name => name)
      item.slug.should eq "my-name-is"
    end

    it "should fill in slug from attribute name if parameterize version of slug is blank" do
      item = Item.create!(:name => "my name is", :slug => "/")
      item.slug.should eq "my-name-is"
    end

    it "should only parametrize slug attribute if slug is present" do
      item = Item.create!(:name => "my name is", :slug => "my url")
      item.slug.should eq "my-url"
    end
  end

  context "given options" do
    it "should create fill_slug_from_title_to_seo_url" do
      Page.new.should respond_to :fill_slug_from_title_to_seo_url
    end

    it "should create format_slug_from_title_to_seo_url" do
      Page.new.should respond_to :format_slug_from_title_to_seo_url
    end

    it "should fill in slug parameter from attribute title and parametrize it" do
      page = Page.create!(:title => "my name is")
      page.seo_url.should eq "my-name-is"
    end

    it "should fill in slug parameter from attribute title if parameterize version of slug is blank" do
      page = Page.create!(:title => "my name is", :seo_url => "/")
      page.seo_url.should eq "my-name-is"
    end

    it "should only parametrize slug attribute if slug is present" do
      page = Page.create!(:title => "my name is", :seo_url => "my url")
      page.seo_url.should eq "my-url"
    end

    it "should be able to change parameterize method" do
      name = "product"
      name.should_receive(:my_formatter).and_return("hello")
      product = Product.create!(:name => "my name is", :slug => name)
      product.slug.should eq "hello"
    end

    it "should be able to disable tree caching" do
      tree_item = TreeItem.create!(:name => "my name is", :parent => TreeItem.create!(:name => "root"))
      tree_item.should_receive(:path).and_return([])
      tree_item.to_slug
      tree_item.should_receive(:path).and_return([])
      tree_item.to_slug

      tree_item = Category.create!(:name => "my name is", :parent => Category.create!(:name => "root"))
      tree_item.should_not_receive(:path)
      tree_item.to_slug
    end
  end

  describe "to_slug" do
    context "default options" do
      it "should define method to_seo_url" do
        Item.new.should respond_to :to_slug
      end

      it "should return slug in string" do
        item = Item.create!(:name => "my name is", :slug => "my-url")
        item.to_slug.should eq "my-url"
      end
    end

    context "given options" do
      it "should define method to_seo_url" do
        Page.new.should respond_to :to_seo_url
      end

      it "should return slug in string" do
        page = Page.create!(:title => "my name is", :seo_url => "my-url")
        page.to_seo_url.should eq "my-url"
      end
    end

    context "ancestry model" do
      it "should return array of slugs" do
        root = Category.create!(:name => "root", :slug => "root")
        child = Category.new(:name => "child", :slug => "child")
        child.parent = root
        child.save!

        child.to_slug.should eq ["root", "child"]
      end
    end
  end

  describe "to_slug_was" do
    context "default options" do
      it "should define method to_slug_was" do
        Item.new.should respond_to :to_slug_was
      end

      it "should return old slug in string" do
        item = Item.create!(:name => "my name is", :slug => "my-url")
        item.slug = "new-slug"
        item.to_slug_was.should eq "my-url"
      end
    end

    context "given options" do
      it "should define method to_seo_url_was" do
        Page.new.should respond_to :to_seo_url_was
      end

      it "should return future slug in string" do
        page = Page.create!(:title => "my name is", :seo_url => "my-url")
        page.seo_url = "hello-world"
        page.to_seo_url_was.should eq "my-url"
      end
    end

    context "ancestry model" do
      it "should return array of old slugs" do
        root = Category.create!(:name => "root", :slug => "root")
        child = Category.new(:name => "child", :slug => "child")
        child.save!

        child.parent = root
        child.slug = "moved"
        child.to_slug_was.should eq ["child"]
      end
    end
  end

  describe "to_slug_will" do
    context "default options" do
      it "should define method to_slug_will" do
        Item.new.should respond_to :to_slug_will
      end

      it "should return future slug in string" do
        item = Item.create!(:name => "my name is", :slug => "my-url")
        item.slug = "new slug"
        item.to_slug_will.should eq "new-slug"
      end
    end

    context "given options" do
      it "should define method to_seo_url_will" do
        Page.new.should respond_to :to_seo_url_will
      end

      it "should return slug in string" do
        page = Page.create!(:title => "my name is", :seo_url => "my-url")
        page.seo_url = "hello world"
        page.to_seo_url_will.should eq "hello-world"
      end
    end

    context "ancestry model" do
      it "should return array of slugs" do
        root = Category.create!(:name => "root", :slug => "root")
        child = Category.new(:name => "child", :slug => "child")
        child.save!

        child.parent = root
        child.slug = "move d"
        child.to_slug_will.should eq ["root", "move-d"]
      end
    end
  end

  describe "ancestry methods" do
    describe "all_slugs" do
      it "ancestry model class should respond to all_slugs" do
        Category.should respond_to :all_slugs
      end

      it "should return all slugs in hash where key is id and value is slug by itself" do
        root = Category.create!(:name => "root", :slug => "root")
        child = Category.new(:name => "child", :slug => "child")
        child.parent = root
        child.save!

        Category.all_slugs.should eq({root.id => "root", child.id => "child"})
      end

      it "should update slug cache after save" do
        root = Category.create!(:name => "root", :slug => "root")
        Category.all_slugs.should eq({root.id => "root"})

        child = Category.new(:name => "child", :slug => "child")
        child.save! # force save
        Category.all_slugs.should eq({root.id => "root", child.id => "child"})

        child.slug = "updated-child"
        child.save # standard save
        Category.all_slugs.should eq({root.id => "root", child.id => "updated-child"})
      end
    end

    describe "clear_cached_slugs" do
      it "should clear cache for slug" do
        root = Category.create!(:name => "root", :slug => "root")
        Category.all_slugs.should eq({root.id => "root"})

        root.destroy
        Category.all_slugs.should eq({root.id => "root"})

        Category.clear_cached_slugs
        Category.all_slugs.should eq({})
      end
    end
  end
end