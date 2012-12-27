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
      defaults = {:from => :name, :to => :slug}
      options.reverse_merge!(defaults)
      from = options.delete(:from)
      to = options.delete(:to)
      before_save :"fill_slug_from_#{from}_to_#{to}", :"format_slug_from_#{from}_to_#{to}"
      after_save :"update_my_#{to}_cache"

      # generate this
      #
      # def fill_slug
      #   self.slug = name if slug.blank? || slug.parameterize.blank?
      # end
      code =<<-method
        def fill_slug_from_#{from}_to_#{to}
          self.#{to} = #{from} if #{to}.blank? || #{to}.parameterize.blank?
        end
      method
      class_eval(code)

      # generate this
      #
      # def format_slug
      #   self.slug = slug.parameterize
      # end
      code =<<-method
        def format_slug_from_#{from}_to_#{to}
          self.#{to} = #{to}.parameterize
        end
      method
      class_eval(code)

      # generate this
      # def update_my_slug_cache
      #  @@all ||= {}
      #  @@all[id] = send(:slug)
      # end
      code =<<-method
        def update_my_#{to}_cache
          @@all ||= {}
          @@all[id] = send(:#{to})
        end
      method
      class_eval(code)

      # generate this
      #
      # def self.all_slugs
      #  slug_column = :slug
      #  @@all ||= self.all.map_to_hash{|slug_element| {slug_element.id => slug_element.send(slug_column)}}
      # end
      code =<<-method
        def self.all_#{to}s
          @@all ||= self.all.map_to_hash{|slug_element| {slug_element.id => slug_element.send(:#{to})}}
        end
      method
      class_eval(code)

      # generate this
      #
      # def self.clear_cached_slugs
      #  @@all = nil
      # end
      code =<<-method
        def self.clear_cached_#{to}s
          @@all = nil
        end
      method
      class_eval(code)

      # generate this
      #
      # def self.cached_slug(id)
      #  all_slugs[id]
      # end
      code =<<-method
        def self.cached_#{to}(id)
          all_#{to}s[id].to_s
        end
      method
      class_eval(code)

      # generate this
      #
      # def to_slug
      #  if respond_to?(:path_ids)
      #    slugs = path.map{|record| record.send(:"slug")}.select{|i| i.size > 0 }
      #    if slugs.empty?
      #      ""
      #    else
      #      slug
      #    end
      #  else
      #    send(:slug)
      #  end
      # end
      code =<<-method
        def to_#{to}
          if respond_to?(:path_ids)
            slugs = path.map{|record| record.send(:"#{to}")}.select{|i| i.size > 0 }
            if slugs.empty?
              ""
            else
              slugs
            end
          else
            send(:#{to})
          end
        end
      method
      class_eval(code)
    end

  end
end