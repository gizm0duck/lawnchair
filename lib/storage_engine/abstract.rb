module Lawnchair
  module StorageEngine
    class Abstract
      class << self
        attr_reader :cache_container
        
        def cache_container
          @cache_container ||= {}
        end
      
        def fetch(key, options, &block)
          if exists?(key)
            value = get(key, options)
          else
            value = block.call
            set(key, value, options)
          end
          value
        end
      
        def get(key, options={})
          if options[:raw]
            cache_container[computed_key(key)]
          else
            exists?(key) ? Marshal.load(cache_container[computed_key(key)]) : nil
          end
        end
      
        def computed_key(key)
          raise "Missiing key" if key.nil? || key.empty?
          prefix = "Lawnchair"
          "#{prefix}:#{key}"
        end
      end
    end
  end
end