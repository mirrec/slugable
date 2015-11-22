require 'slugable/cache_layer'
require 'active_support/core_ext/string/inflections'

describe Slugable::CacheLayer do
  MyModel = Class.new

  let(:model) { MyModel }
  let(:cache_storage) { double(:cache_storage) }

  subject { Slugable::CacheLayer.new(cache_storage, model) }

  describe '#read_slug' do
    it 'use fetch for reading value for slug from cache storage' do
      cache_storage.stub(:fetch).with('my_model/slug_column/1').and_return('hello')

      subject.read_slug(:slug_column, 1).should eq 'hello'
    end

    it 'passes block that will be executed if cache storage does not have given value yet' do
      model.stub(:find).with(1).and_return(double(:record, slug_column: 'hello'))

      cache_storage.stub(:fetch).with('my_model/slug_column/1').and_yield

      subject.read_slug(:slug_column, 1).should eq 'hello'
    end
  end

  describe '#update' do
    it 'writes new value to cache storage' do
      cache_storage.should_receive(:write).with('my_model/slug_column/1', 'hello')

      subject.update(:slug_column, 1, 'hello')
    end
  end
end
