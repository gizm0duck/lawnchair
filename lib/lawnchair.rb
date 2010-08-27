require 'rubygems'
require 'redis'
require 'storage_engine/abstract'
require 'storage_engine/redis'
require 'storage_engine/in_process'
require 'storage_engine/composite'

if defined? RAILS_ENV
  require 'active_record_extension'
  require 'marshal_extension'
  require 'view/helper'
end

module Lawnchair
  class << self
    attr_reader :redis
    
    def cache(key, options={}, &block)
      if options[:in_process]
        store = Lawnchair::StorageEngine::Composite.new(:in_process, :redis)
      else
        store = Lawnchair::StorageEngine::Redis
      end
      interpolate(options[:interpolate]) do
        store.fetch(key, options, &block)
      end
    end

    def connectdb(redis=nil)
      @redis = (redis || Redis.new(:db => 11))
    end

    def flushdb
      redis.flushdb
    end
    
    def interpolate(interpolations, &block)
      interpolations ||= {}
      interpolations.inject(block.call){|cached_data, interpolated_data| cached_data.gsub(interpolated_data.first, interpolated_data.last) }
    end
  end
  
  class Cache
    # <b>DEPRECATED:</b> Please use <tt>Lawnchair.cache</tt> instead.
    def self.me(key, options={}, &block)
      warn "[DEPRECATION] 'Lawnchair::Cache.me' is deprecated.  Please use 'Lawnchair.cache' instead."
      Lawnchair.cache(key, options, &block)
    end
  end
end

