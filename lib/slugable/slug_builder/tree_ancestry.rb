module Slugable
  module SlugBuilder
    class TreeAncestry
      attr_reader :record, :slug_column, :formatter

      def initialize(record, slug_column, options)
        @record = record
        @slug_column = slug_column
        @formatter = options.fetch(:formatter)
      end

      def to_slug
        slugs = record.path.map{ |record| record.public_send(slug_column) }.compact.select{ |i| i.size > 0 }
        slugs.empty? ? "" : slugs
      end

      def to_slug_was
        old_slugs = record.ancestry_was.to_s.split("/").map { |ancestor_id| record.class.find(ancestor_id).public_send(slug_column) }
        old_slugs << record.public_send(:"#{slug_column}_was")
      end

      def to_slug_will
        new_slugs = record.ancestry.to_s.split("/").map { |ancestor_id| record.class.find(ancestor_id).public_send(slug_column) }
        new_slugs << formatter.call(record.public_send(slug_column))
        new_slugs
      end
    end
  end
end
