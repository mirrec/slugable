module Slugable
  class Railtie < Rails::Railtie
    initializer "slugable.active_record_ext" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :extend, Slugable::HasSlug
      end
    end
  end
end