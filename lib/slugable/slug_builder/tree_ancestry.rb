module Slugable
  module SlugBuilder
    class TreeAncestry
      attr_reader :slug_column, :formatter

      def initialize(options)
        @slug_column = options.fetch(:slug_column)
        @formatter = options.fetch(:formatter)
      end

      def to_slug(record)
        record.path.map{ |path_record| path_record.public_send(slug_column) }.select(&:present?)
      end

      def to_slug_was(record)
        old_slugs = record.ancestry_was.to_s.split('/').map { |ancestor_id| record.class.find(ancestor_id).public_send(slug_column) }
        old_slugs << record.public_send(:"#{slug_column}_was")
        old_slugs
      end

      def to_slug_will(record)
        new_slugs = record.ancestry.to_s.split('/').map { |ancestor_id| record.class.find(ancestor_id).public_send(slug_column) }
        new_slugs << formatter.call(record.public_send(slug_column))
        new_slugs
      end
    end
  end
end
