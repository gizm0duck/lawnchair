module Lawnchair
  module StorageEngine
    class Composite
      attr_reader :storage_engines
    
      def initialize(*args)
        @storage_engines = []
        args.each do |arg|
          register_storage_engine arg
        end
      end
      
      def register_storage_engine(storage_engine)
        klass = storage_engine == :redis ? "Redis" : "InProcess"
        storage_engines << Object.module_eval("Lawnchair::StorageEngine::#{klass}")
      end
    
      def fetch(key, options, &block)
        raise "No Storage Engines Configured" if storage_engines.empty?
        
        value, index = find_in_storage(key, options)
        value ||= yield
        place_in_storage(key, value, options, index)
      end
      
      private
      
      def find_in_storage(key, options)
        value, index = nil, nil
        storage_engines.each_with_index do |storage_engine, i|
          if storage_engine.exists?(key)
            value = storage_engine.get(key, options)
            index = i
            break
          end
        end
        return value, index
      end
      
      def place_in_storage(key, value, options, index)
        storage_engines.each_with_index do |storage_engine, i|
          break if i == index
          storage_engine.set(key, value, options)
        end
        value
      end
    end
  end
end