module Lawnchair
  module StorageEngine
    class Abstract
      class << self
        attr_reader :data_store
        
        def data_store
          @data_store ||= {}
        end
      
        def fetch(key, options={}, &block)
          if self.db_connection?
            if exists?(key)
              value = get(key, options)
            else
              value = block.call
              set(key, value, options)
              return value
            end
          else
            block.call
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
          raise "Missing key" if key.nil? || key.empty?
          key.gsub!(" ","") if key.match(/\s/)
          prefix = "Lawnchair"
          "#{prefix}:#{key}"
        end
        
        def db_connection?
          true
        end
      end
    end
  end
end