require 'spec_helper'
require 'support/set_up_models'

describe Slugable::SlugBuilder::CachingTreeAncestry do
  let(:cache) { double(:cache) }

  subject {
    Slugable::SlugBuilder::CachingTreeAncestry.new(
        slug_column: :slug,
        formatter: lambda { |string| "#{string}-formatted" },
        cache: cache,
    )
  }

  let(:model) { TreeCategory }

  describe '#to_slug' do
    it 'returns array of slugs column from record path that are loaded from cache' do
      root = model.create!(slug: 'root')
      child = model.create!(slug: 'child', parent: root)

      allow(cache).to receive(:read_slug).with(:slug, root.id).and_return('root-cached')
      allow(cache).to receive(:read_slug).with(:slug, child.id).and_return('child-cached')

      expect(subject.to_slug(child)).to eq ['root-cached', 'child-cached']
    end

    it 'removes blank values from array of record path' do
      root = model.create!(slug: 'root')
      child = model.create!(slug: 'child', parent: root)

      allow(cache).to receive(:read_slug).with(:slug, root.id).and_return('')
      allow(cache).to receive(:read_slug).with(:slug, child.id).and_return(nil)

      expect(subject.to_slug(child)).to eq []
    end
  end
end