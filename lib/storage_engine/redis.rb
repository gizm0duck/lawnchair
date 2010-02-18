module Lawnchair
  module StorageEngine
    class Redis < Abstract
      class << self
        attr_reader :db_connection
        
        def data_store
          Lawnchair.redis
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
        
        def connection_established!
          verify_db_connection
        end
        
        def db_connection?
          return @db_connection unless @db_connection.nil?
          verify_db_connection
        end
        
        def verify_db_connection
          begin
            data_store.info
            @db_connection = true
          rescue Exception => e
            @db_connection = false
          ensure
            return @db_connection
          end
        end
      end
    end
  end
end