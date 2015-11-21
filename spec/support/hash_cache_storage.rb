class HashCacheStorage
  attr_reader :store

  def initialize
    @store = {}
  end

  def fetch(key, options = nil, &block)
    store.fetch(key) {
      value = block.call
      store[key] = value
      value
    }
  end

  def clear(options = nil)
    @store = {}
  end

  def read(key, options = nil)
    store[key]
  end

  def write(key, value, options = nil)
    store[key] = value
  end
end