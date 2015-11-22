require 'spec_helper'
require 'support/set_up_models'

describe Slugable::SlugBuilder::Flat do
  subject {
    Slugable::SlugBuilder::Flat.new(
        slug_column: :slug,
        formatter: lambda { |string| "#{string}-formatted" }
    )
  }

  let(:model) { FlatItem }

  describe '#to_slug' do
    it 'returns value from record column' do
      record = model.new(slug: 'value')
      expect(subject.to_slug(record)).to eq 'value'

      record = model.create!(slug: 'value')
      expect(subject.to_slug(record)).to eq 'value'
    end
  end

  describe '#to_slug_was' do
    it 'returns old value from record'do
      record = model.create!(slug: 'value')
      record.slug = 'new-value'
      expect(subject.to_slug_was(record)).to eq 'value'
    end
  end

  describe '#to_slug_will' do
    it 'returns future value of record' do
      record = model.new(slug: 'value')
      expect(subject.to_slug_will(record)).to eq 'value-formatted'

      record = model.create!(slug: 'value')
      record.slug = 'new-value'
      expect(subject.to_slug_will(record)).to eq 'new-value-formatted'
    end
  end
end