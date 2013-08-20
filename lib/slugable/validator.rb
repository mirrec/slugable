module Slugable
  module Validator
    def self.validate(record, to)
      base  = record.class
      value = record.read_attribute(to)

      return unless value.present?

      other = base.where(to => value).first

      other.nil? || other.respond_to?(:parent_id) && other.parent_id != record.parent_id
    end
  end
end
