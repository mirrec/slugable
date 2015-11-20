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

    class MethodBuilder
      def self.build(model, options)
        # constructing slug
        # building to_slug, to_slug_was, to_slug_will
        # caching slug

        defaults = {:from => :name, :to => :slug, :formatter => :parameterize, :cache_tree => true}
        options.reverse_merge!(defaults)
        from = options.delete(:from)
        to = options.delete(:to)
        formatter = options.delete(:formatter)
        cache_tree = options.delete(:cache_tree)

        model.class_eval do
          class_variable_set(:@@all, nil)

          before_save :"prepare_slug_in_#{to}"
          after_save :"update_my_#{to}_cache"

          define_method :"prepare_slug_in_#{to}" do
            if public_send(to).blank? || public_send(to).public_send(:"#{formatter}").blank?
              public_send(:"#{to}=", public_send(from))
            end
            public_send(:"#{to}=", public_send(to).public_send(:"#{formatter}"))
          end

          define_method :"to_#{to}" do
            if respond_to?(:path_ids)
              slugs = if cache_tree
                        path_ids.map{ |id| self.class.public_send(:"cached_#{to}", id) }.compact.select{|i| i.size > 0 }
                      else
                        path.map{ |record| record.public_send(:"#{to}")}.compact.select{|i| i.size > 0 }
                      end
              slugs.empty? ? "" : slugs
            else
              public_send(to)
            end
          end

          define_method :"to_#{to}_was" do
            if respond_to?(:ancestry_was)
              old_slugs = if cache_tree
                            ancestry_was.to_s.split("/").map { |ancestor_id| self.class.public_send(:"cached_#{to}", ancestor_id.to_i) }
                          else
                            ancestry_was.to_s.split("/").map { |ancestor_id| self.class.find(ancestor_id).public_send(to) }
                          end
              old_slugs << public_send(:"#{to}_was")
            else
              public_send(:"#{to}_was")
            end
          end

          define_method :"to_#{to}_will" do
            if respond_to?(:ancestry)
              new_slugs = if cache_tree
                            ancestry.to_s.split("/").map { |ancestor_id| self.class.public_send(:"cached_#{to}", ancestor_id.to_i) }
                          else
                            ancestry.to_s.split("/").map { |ancestor_id| self.class.find(ancestor_id).public_send(to) }
                          end
              new_slugs << public_send(to).public_send(formatter)
            else
              public_send(to).public_send(formatter)
            end
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
  end
end