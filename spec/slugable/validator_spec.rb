require 'spec_helper'

describe Slugable::Validator do
  let(:base)      { double(:base) }
  let(:record)    { double(:record) }
  let(:validator) { described_class }

  describe '#validate' do
    context 'when validating slug presence' do
      it 'should not mark record as valid if missing slug value' do
        record.should_receive(:class).and_return(base)
        record.should_receive(:read_attribute).with(:slug).and_return('')

        validator.validate(record, :slug).should be_false
      end
    end

    context 'when validating uniqueness' do
      it 'should not mark record as valid already exists' do
        other = double(:other)

        record.should_receive(:class).and_return(base)
        record.should_receive(:read_attribute).with(:slug).and_return('value')
        base.should_receive(:where).with(:slug  => 'value').and_return([other])
        other.should_receive(:respond_to?).with(:parent_id).and_return(false)

        validator.validate(record, :slug).should be_false
      end
    end

    context 'when validating ancestry parenthood' do
      it 'should mark record as valid unless shares parent' do
        other = double(:other)

        record.should_receive(:class).and_return(base)
        record.should_receive(:read_attribute).with(:slug).and_return('value')
        base.should_receive(:where).with(:slug  => 'value').and_return([other])
        other.should_receive(:respond_to?).with(:parent_id).and_return(true)
        other.should_receive(:parent_id).and_return(2)
        record.should_receive(:parent_id).and_return(1)

        validator.validate(record, :slug).should be_true
      end
    end
  end
end
