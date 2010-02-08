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
    def self.me(options = {}, &block)
      raise "Cache key please!" unless options.has_key?(:key)
      
      if exists?(options[:key])
        Marshal.load(Lawnchair.redis[compute_key(options[:key])])
      else
        val = block.call
        expires_in = compute_expiry(options[:expires_in])
        Lawnchair.redis.set(compute_key(options[:key]), Marshal.dump(val), expires_in)
        return val
      end
    end
    
    def self.compute_key(key)
      "Lawnchair:#{key}"
    end
    
    def self.expire(key)
      Lawnchair.redis.del(compute_key(key))
    end
    
    def self.exists?(key)
      return Lawnchair.redis.exists(compute_key(key))
    end
    
    def self.compute_expiry(seconds)
      seconds || 3600
    end
  end
end