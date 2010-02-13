require 'rubygems'
require 'redis'
Dir[File.dirname(__FILE__) + '/storage_engine/*.rb'].each {|file| require file }
require 'view/helper'

module Lawnchair
  class Cache
    def self.me(key, options={}, &block)
      if options[:in_process]
        store = initialize_composite_store
      else
        store = Lawnchair::StorageEngine::Redis
      end
      store.fetch(key, options, &block)
    end
    
    def self.initialize_composite_store
      composite_store = Lawnchair::StorageEngine::Composite.new
      composite_store.register_storage_engine(Lawnchair::StorageEngine::InProcess)
      composite_store.register_storage_engine(Lawnchair::StorageEngine::Redis)
      composite_store
    end
  end
  
  class << self
    attr_reader :redis

    def connectdb(redis=nil)
      @redis = (redis || Redis.new(:db => 11))
    end

    def flushdb
      redis.flushdb
    end
  end
end