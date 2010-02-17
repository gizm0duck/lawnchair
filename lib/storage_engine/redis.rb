module Lawnchair
  module StorageEngine
    class Redis < Abstract
      class << self
        def data_store
          Lawnchair.redis
        end
        
        def db_required
          true
        end
    
        def set(key, value, options={})
          ttl = options[:expires_in] || 3600
          if options[:raw]
            data_store.set(computed_key(key), value, ttl)
          else
            data_store.set(computed_key(key), Marshal.dump(value), ttl)
          end
        end
  
        def exists?(key)
          data_store.exists(computed_key(key))
        end
  
        def expire!(key)
          data_store.del(computed_key(key))
        end
      end
    end
  end
end