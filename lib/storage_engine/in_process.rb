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
            cache_container[computed_key(key)] = value
          else
            cache_container[computed_key(key)] = Marshal.dump(value)
          end
        end

        def exists?(key)
          cache_container.has_key?(computed_key(key))
        end
  
        def expire!(key)
          cache_container.delete(computed_key(key))
        end
      end
    end
  end
end