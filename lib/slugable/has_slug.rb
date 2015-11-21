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
    def has_slug(options = {})
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

    class CacheLayer
      attr_reader :storage, :model

      def initialize(storage, model)
        @storage = storage
        @model = model
      end

      def read(slug_column, id)
        storage.fetch(cache_key(slug_column, id)) { model.find(id).public_send(slug_column) }
      end

      def update(slug_column, id, value)
        storage.write(cache_key(slug_column, id), value)
      end

      private

      def cache_key(slug_column, id)
        "#{model.to_s.underscore}/#{slug_column}/#{id}"
      end
    end

    class MethodBuilder
      def self.build(model, options)
        defaults = {:from => :name, :to => :slug, :formatter => ParameterizeFormatter, :cache_storage => nil}

        options.reverse_merge!(defaults)
        from = options.delete(:from)
        to = options.delete(:to)
        formatter = options.delete(:formatter)
        cache_storage = options.delete(:cache_storage)
        cache_layer = nil
        if cache_storage
          cache_layer = CacheLayer.new(cache_storage, self.class)
        end

        model.class_eval do
          before_save :"prepare_slug_in_#{to}"
          if cache_layer
            after_save :"update_my_#{to}_cache"
          end

          define_method :"slug_builder_for_#{to}" do
            if respond_to?(:path_ids)
              if cache_layer
                Slugable::HasSlug::CachingAncestrySlugBuilder.new(self, to, :formatter => formatter, :cache => cache_layer)
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

          if cache_layer
            define_method :"update_my_#{to}_cache" do
              cache_layer.update(to, id, public_send(to))
            end
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