module Slugable
  module SlugBuilder
    class CachingTreeAncestry < TreeAncestry
      attr_reader :cache

      def initialize(record, slug_column, options)
        super
        @cache = options.fetch(:cache)
      end

      def to_slug
        slugs = record.path_ids.map{ |id| cache.read(slug_column, id) }.compact.select{|i| i.size > 0 }
        slugs.empty? ? "" : slugs
      end
    end
  end
end
