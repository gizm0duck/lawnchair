require 'rubygems'
require 'redis'

module Lawnchair
  
  class << self
    attr_reader :redis
    
    def connectdb(redis=nil)
      @redis ||= Redis.new(:db => 11)
    end

    def flushdb
      redis.flushdb
    end
  end
  
  class Cache
    @@in_process_store = {}
    
    def self.in_process_store
      @@in_process_store
    end
    
    def self.me(options = {}, &block)
      raise "Cache key please!" unless options.has_key?(:key)
        
      if exists?(options[:key], options[:in_process]) && !options[:force]
        if options[:in_process]
          Marshal.load(@@in_process_store[compute_key(options[:key])])
        else
          Marshal.load(Lawnchair.redis[compute_key(options[:key])])
        end
      else
        if options[:in_process] && exists?(options[:key])
          cached_val = Lawnchair.redis[compute_key(options[:key])]
          @@in_process_store[compute_key(options[:key])] = cached_val
          return Marshal.dump(cached_val)
        end
        
        val = block.call
        expires_in = compute_expiry(options[:expires_in])
        dumped_val = Marshal.dump(val)        
        @@in_process_store[compute_key(options[:key])] = dumped_val if options[:in_process]
        Lawnchair.redis.set(compute_key(options[:key]), dumped_val, expires_in)
        return val
      end
    end
    
    def self.compute_key(key)
      "Lawnchair:#{key}"
    end
    
    def self.expire(key)
      Lawnchair.redis.del(compute_key(key))
    end
    
    def self.exists?(key, in_process=false)
      if in_process
        @@in_process_store.has_key?(compute_key(key))
      else
        return Lawnchair.redis.exists(compute_key(key))
      end
    end
    
    def self.compute_expiry(seconds)
      seconds || 3600
    end
  end
end