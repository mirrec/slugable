module Slugable
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
end