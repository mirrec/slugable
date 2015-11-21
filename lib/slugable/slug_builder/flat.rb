module Slugable
  module SlugBuilder
    class Flat
      attr_reader :slug_column, :formatter

      def initialize(options)
        @slug_column = options.fetch(:slug_column)
        @formatter = options.fetch(:formatter)
      end

      def to_slug(record)
        record.public_send(slug_column)
      end

      def to_slug_was(record)
        record.public_send(:"#{slug_column}_was")
      end

      def to_slug_will(record)
        formatter.call(record.public_send(slug_column))
      end
    end
  end
end