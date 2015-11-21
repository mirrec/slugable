module Slugable
  module HasSlug
    #
    # USAGE
    # generate before save filter for filling slug from name attribute, and parameterize slug attribute
    # you can change default columns by passing :from and :to attributes
    #
    # it also generate method to_slug (depanding od :to param), which generate slug url for link_path
    #
    # has_slug                                # generate to_slug
    # has_slug :from => :title                # generate to_slug
    # has_slug :to => :seo_url                # generate to_url
    # has_slug :from => :name, :to => :slug   # generate to_slug
    #
    def has_slug(options={})
      MethodBuilder.build(self, options)
    end

    class FlatSlugBuilder
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

    class AncestrySlugBuilder
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

    class CachingAncestrySlugBuilder < AncestrySlugBuilder
      attr_reader :record, :slug_column, :formatter, :cache

      def initialize(record, slug_column, options)
        super
        @cache = options.fetch(:cache)
      end

      def to_slug
        slugs = record.path_ids.map{ |id| cache.public_send(:"cached_#{slug_column}", id) }.compact.select{|i| i.size > 0 }
        slugs.empty? ? "" : slugs
      end
    end

    class MethodBuilder
      def self.build(model, options)
        # constructing slug
        # building to_slug, to_slug_was, to_slug_will
        # caching slug

        defaults = {:from => :name, :to => :slug, :formatter => ParameterizeFormatter, :cache_tree => true}
        options.reverse_merge!(defaults)
        from = options.delete(:from)
        to = options.delete(:to)
        formatter = options.delete(:formatter)
        cache_tree = options.delete(:cache_tree)

        model.class_eval do
          class_variable_set(:@@all, nil)

          before_save :"prepare_slug_in_#{to}"
          after_save :"update_my_#{to}_cache"

          define_method :"slug_builder_for_#{to}" do
            if respond_to?(:path_ids)
              if cache_tree
                Slugable::HasSlug::CachingAncestrySlugBuilder.new(self, to, :formatter => formatter, :cache => self.class)
              else
                Slugable::HasSlug::AncestrySlugBuilder.new(self, to, :formatter => formatter)
              end
            else
              Slugable::HasSlug::FlatSlugBuilder.new(self, to, :formatter => formatter)
            end
          end

          define_method :"prepare_slug_in_#{to}" do
            if public_send(to).blank? || formatter.call(public_send(to)).blank?
              public_send(:"#{to}=", public_send(from))
            end
            public_send(:"#{to}=", formatter.call(public_send(to)))
          end

          define_method :"to_#{to}" do
            public_send(:"slug_builder_for_#{to}").to_slug
          end

          define_method :"to_#{to}_was" do
            public_send(:"slug_builder_for_#{to}").to_slug_was
          end

          define_method :"to_#{to}_will" do
            public_send(:"slug_builder_for_#{to}").to_slug_will
          end

          define_method :"update_my_#{to}_cache" do
            self.class.class_variable_set(:@@all, self.class.class_variable_get(:@@all) || {})
            self.class.class_variable_get(:@@all)[id] = public_send(to)
          end

          define_singleton_method :"all_#{to}s" do
            class_variable_set(
                :"@@all",
                class_variable_get(:"@@all") ||
                    all.map_to_hash{ |slug_element| { slug_element.id => slug_element.public_send(to) } }
            )
          end

          define_singleton_method :"clear_cached_#{to}s" do
            class_variable_set(:"@@all", nil)
          end

          define_singleton_method :"cached_#{to}" do |id|
            public_send(:"all_#{to}s")[id].to_s
          end
        end
      end
    end

    class ParameterizeFormatter
      def self.call(string)
        string.parameterize
      end
    end
  end
end