require 'active_support'
require 'active_record'
module ActiveRecord
  module LawnchairExtension
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods      
      def lawnchair_cache(method, options={})
        self.class_eval %{
          def #{method}_with_lawnchair(*args)
            ident = lambda { |obj| obj.class.respond_to?(:primary_key) ? obj.send(obj.class.primary_key) : obj.to_s }
            arg_keys = args.map(&ident).join(':')
            key = "#\{self.class.name\}:#{method}:#\{ident.call(self)\}:#\{arg_keys\}"
            Lawnchair.cache(key, #{options.inspect}) do
              self.#{method}_without_lawnchair(*args)
            end
          end
        }

        alias_method_chain method, :lawnchair
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::LawnchairExtension
end