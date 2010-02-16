module Lawnchair
  module StorageEngine
    class Abstract
      class << self
        attr_reader :data_store
        
        def data_store
          @data_store ||= {}
        end
      
        def fetch(key, options={}, &block)
          begin
            if exists?(key)
              value = get(key, options)
            else
              value = block.call
              set(key, value, options)
            end
          rescue Errno::ECONNREFUSED => e
            value = block.call
          ensure
            return value
          end
        end
      
        def get(key, options={})
          if options[:raw]
            data_store[computed_key(key)]
          else
            exists?(key) ? Marshal.load(data_store[computed_key(key)]) : nil
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