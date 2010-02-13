module Lawnchair
  module StorageEngine
    class InProcess < Abstract
      @@data_store = {}
      class << self
    
        def data_store
          @@data_store
        end
    
        def set(key, value, options={})
          if options[:raw]
            data_store[computed_key(key)] = value
          else
            data_store[computed_key(key)] = Marshal.dump(value)
          end
        end

        def exists?(key)
          data_store.has_key?(computed_key(key))
        end
  
        def expire!(key)
          data_store.delete(computed_key(key))
        end
      end
    end
  end
end