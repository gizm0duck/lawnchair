module Lawnchair
  module StorageEngine
    class InProcess < Abstract
      @@cache_container = {}
      class << self
    
        def cache_container
          @@cache_container
        end
    
        def set(key, value, options={})
          if options[:raw]
            cache_container[key] = value
          else
            cache_container[key] = Marshal.dump(value)
          end
        end

        def exists?(key)
          cache_container.has_key?(key)
        end
  
        def expire!(key)
          cache_container.delete(key)
        end
      end
    end
  end
end