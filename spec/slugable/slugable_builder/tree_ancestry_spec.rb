require 'spec_helper'
require 'support/set_up_models'

describe Slugable::SlugBuilder::TreeAncestry do
  subject {
    Slugable::SlugBuilder::TreeAncestry.new(
        slug_column: :slug,
        formatter: lambda { |string| "#{string}-formatted" }
    )
  }

  let(:model) { TreeCategory }

  describe '#to_slug' do
    it 'returns array of slugs column from record path' do
      root = model.create!(slug: 'root')
      child = model.create!(slug: 'child', parent: root)
      expect(subject.to_slug(child)).to eq ['root', 'child']
    end

    it 'removes blank values from array of record path' do
      child = model.new(slug: '')
      expect(subject.to_slug(child)).to eq []

      child = model.new(slug: nil)
      expect(subject.to_slug(child)).to eq []
    end
  end

  describe '#to_slug_was' do
    it 'returns old value of slug using old ancestry and slug_was from record' do
      root = model.create!(slug: 'root')
      child = model.create!(slug: 'child', parent: root)

      new_root = model.create!(slug: 'new-root')
      child.parent = new_root
      child.slug = 'new-child'

      expect(subject.to_slug_was(child)).to eq ['root', 'child']
    end
  end

  describe '#to_slug_will' do
    it 'returns future value of slugs in record path' do
      root = model.create!(slug: 'root')
      child = model.create!(slug: 'child', parent: root)

      new_root = model.create!(slug: 'new-root')
      child.parent = new_root
      child.slug = 'new-child'

      expect(subject.to_slug_will(child)).to eq ['new-root', 'new-child-formatted']
    end
  end
end