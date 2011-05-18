module Lawnchair
  module StorageEngine
    class Abstract
      class << self
        attr_reader :data_store
        
        def data_store
          @data_store ||= {}
        end
      
        def fetch(key, options={}, &block)
          start_time = Time.now
          if value = get(key, options)
            log("HIT", key, Time.now-start_time)
            return value
          else
            value = block.call
            set(key, value, options)
            log("MISS", key, Time.now-start_time)
            return value
          end
        end
      
        def get(key, options={})
          if options[:raw]
            data_store[computed_key(key)]
          else
            value = data_store[computed_key(key)]
            value.nil? ? nil : Marshal.load(value)
          end
        end
      
        def computed_key(key)
          raise "Missing key" if key.nil? || key.empty?
          prefix = "Lawnchair"
          "#{prefix}:#{key}"
        end
        
        def db_connection?
          true
        end
        
        def log(message, key, elapsed)
          Lawnchair.redis.hincrby(message, computed_key(key), 1)
          ActionController::Base.logger.info("Lawnchair Cache: #{message} (%0.6f secs): #{key}" % elapsed) if defined? ::ActionController::Base
        end
      end
    end
  end
end