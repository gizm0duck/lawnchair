module Lawnchair
  class Cache
    def self.please(options = {}, &block)
      raise "Cache key please!" unless options.has_key?(:key)
    end
  end
end