require 'rubygems'
require 'redis'

module Lawnchair
  
  class << self
    attr_reader :redis
  end
  
  def self.connectdb(redis=nil)
    @redis ||= Redis.new(:db => 11)
  end
  
  def self.flushdb
    redis.flushdb
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
      Lawnchair.redis.del compute_key(key)
    end
    
    def self.exists?(key)
      return !!Lawnchair.redis[compute_key(key)]
    end
    
    def self.compute_expiry(ms)
      ms ||= 3600000
      ms/1000
    end
  end
end