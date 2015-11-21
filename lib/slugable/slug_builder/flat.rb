module Slugable
  module SlugBuilder
    class Flat
      attr_reader :record, :slug_column, :formatter

      def initialize(record, slug_column, options)
        @record = record
        @slug_column = slug_column
        @formatter = options.fetch(:formatter)
      end

      def to_slug
        record.public_send(slug_column)
      end

      def to_slug_was
        record.public_send(:"#{slug_column}_was")
      end

      def to_slug_will
        formatter.call(record.public_send(slug_column))
      end
    end
  end
end