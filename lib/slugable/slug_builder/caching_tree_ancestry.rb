module Slugable
  module SlugBuilder
    class CachingTreeAncestry < TreeAncestry
      attr_reader :cache

      def initialize(options)
        super
        @cache = options.fetch(:cache)
      end

      def to_slug(record)
        record.path_ids.map{ |id| cache.read_slug(slug_column, id) }.select(&:present?)
      end
    end
  end
end
