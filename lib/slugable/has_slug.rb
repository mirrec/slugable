module Slugable
  Configuration = Struct.new(:formatter, :tree_cache_storage)

  def self.configuration
    @configuration ||= Configuration.new(
        Slugable::Formatter::Parameterize,
        nil
    )
  end

  def self.configure
    yield configuration
  end

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

    class MethodBuilder
      def self.build(model, options)
        defaults = {
            :from => :name,
            :to => :slug,
            :formatter => Slugable.configuration.formatter,
            :tree_cache_storage => Slugable.configuration.tree_cache_storage
        }

        options.reverse_merge!(defaults)
        from = options.delete(:from)
        to = options.delete(:to)
        formatter = options.delete(:formatter)
        tree_cache_storage = options.delete(:tree_cache_storage)
        cache_layer = nil
        if tree_cache_storage
          cache_layer = Slugable::CacheLayer.new(tree_cache_storage, self.class)
        end

        model.class_eval do
          before_save :"prepare_slug_in_#{to}"
          if cache_layer
            after_save :"update_my_#{to}_cache"
          end

          define_method :"slug_builder_for_#{to}" do
            if respond_to?(:path_ids)
              if cache_layer
                Slugable::SlugBuilder::CachingTreeAncestry.new(self, to, :formatter => formatter, :cache => cache_layer)
              else
                Slugable::SlugBuilder::TreeAncestry.new(self, to, :formatter => formatter)
              end
            else
              Slugable::SlugBuilder::Flat.new(self, to, :formatter => formatter)
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
  end
end