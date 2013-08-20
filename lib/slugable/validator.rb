module Slugable
  module Validator
    def self.validate(record, to)
      base  = record.class
      value = record.read_attribute(to)

      unless value.present?
        record.errors.add(to, :blank)

        return false
      end

      other = base.where(to => value).first

      if other.nil? || (other.respond_to?(:parent_id) && other.parent_id != record.parent_id)
        return true
      else
        record.errors.add(to, :not_unique)

        return false
      end
    end
  end
end
