module Slugable
  Configuration = Struct.new(:formatter, :tree_cache_storage) do
    def initialize(params)
      params.each { |key, value| public_send(:"#{key}=", value) }
    end
  end

  def self.configuration
    @configuration ||= Configuration.new(
        :formatter          => Slugable::Formatter::Parameterize,
        :tree_cache_storage => nil
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
      def self.default_options
        {
            :from               => :name,
            :to                 => :slug,
            :formatter          => Slugable.configuration.formatter,
            :tree_cache_storage => Slugable.configuration.tree_cache_storage,
            :to_slug_builder    => nil,
        }
      end

      def self.build(model, options)
        options             = options.reverse_merge(default_options)

        from                = options.delete(:from)
        to                  = options.delete(:to)
        formatter           = options.delete(:formatter)
        tree_cache_storage  = options.delete(:tree_cache_storage)
        to_slug_builder     = options.delete(:to_slug_builder)

        cache_layer         = nil
        if tree_cache_storage
          cache_layer = Slugable::CacheLayer.new(tree_cache_storage, model)
          builder_options = {
              :slug_column => to,
              :formatter => formatter,
              :cache => cache_layer
          }
        else
          builder_options = {
              :slug_column => to,
              :formatter => formatter,
          }
        end

        if to_slug_builder.nil?
          builder = Slugable::SlugBuilder::Flat

          if model.respond_to?(:ancestry_column)
            if cache_layer
              builder = Slugable::SlugBuilder::CachingTreeAncestry
            else
              builder = Slugable::SlugBuilder::TreeAncestry
            end
          end
          to_slug_builder = builder.new(builder_options)
        end

        model.class_eval do
          before_save :"prepare_slug_in_#{to}"
          if cache_layer
            after_save :"update_my_#{to}_cache"
          end

          define_method :"slug_builder_for_#{to}" do
            to_slug_builder
          end

          define_method :"prepare_slug_in_#{to}" do
            if public_send(to).blank? || formatter.call(public_send(to)).blank?
              public_send(:"#{to}=", public_send(from))
            end
            public_send(:"#{to}=", formatter.call(public_send(to)))
          end

          define_method :"to_#{to}" do
            public_send(:"slug_builder_for_#{to}").to_slug(self)
          end

          define_method :"to_#{to}_was" do
            public_send(:"slug_builder_for_#{to}").to_slug_was(self)
          end

          define_method :"to_#{to}_will" do
            public_send(:"slug_builder_for_#{to}").to_slug_will(self)
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