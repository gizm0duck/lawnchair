module Lawnchair
  module StorageEngine
    class Redis < Abstract
      class << self
        def cache_container
          Lawnchair.redis
        end
    
        def set(key, value, options={})
          ttl = options[:expires_in] || 3600
          if options[:raw]
            cache_container.set(key, value, ttl)
          else
            cache_container.set(key, Marshal.dump(value), ttl)
          end
        end
  
        def exists?(key)
          cache_container.exists(key)
        end
  
        def expire!(key)
          cache_container.del(key)
        end
      end
    end
  end
end