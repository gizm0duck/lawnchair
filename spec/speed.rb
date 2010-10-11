require 'benchmark'
require "#{File.dirname(__FILE__)}/../lib/lawnchair"
require 'activesupport'
Lawnchair.connectdb
Lawnchair.flushdb

# Totally contrived and fairly useless example... just wanted to make sure the overhead of 
# reading and marshalling the data isn't obscene

# *** Performing 1000 iterations ***
#                       user     system      total        real
# cached:             0.200000   0.050000   0.250000 (  0.397476)
# in process cached:  0.090000   0.010000   0.100000 (  0.088927)
# not cached:         26.710000   0.580000  27.290000 ( 27.331749)
n = (ARGV.shift || 1000).to_i

puts "*** Performing #{n} iterations ***"

def expensive_stuff
  a = []
  100.times do |i|
    a << Time.parse("Dec 3. 1981")
  end
end

Benchmark.bm(7) do |x|
  x.report("cached:\t\t\t") do
    (1..n).each do |i|
      Lawnchair.cache("redis_cache") do
        expensive_stuff
      end
    end
  end
  
  x.report("in process cached:\t") do
    (1..n).each do |i|
      Lawnchair.cache("in_process_cache", :in_process => true) do
        expensive_stuff
      end
    end
  end
  
  x.report("not cached:\t\t") do
    (1..n).each do |i|
      expensive_stuff
    end
  end
end

puts "**** GET vs EXISTS ****"

Benchmark.bm(7) do |x|
  x.report("get: not in cache:\t\t") do
    (1..n).each do |i|
      Lawnchair::StorageEngine::Redis.get("redis_cache")
    end
  end
  
  x.report("exist: not in cache:\t\t") do
    (1..n).each do |i|      
      Lawnchair::StorageEngine::Redis.exists?("redis_cache")
    end
  end
  
  Lawnchair.cache("redis_cache") do
    expensive_stuff
  end
  
  x.report("get: in cache:\t\t\t") do
    (1..n).each do |i|
      Lawnchair::StorageEngine::Redis.get("redis_cache")
    end
  end
  
  x.report("exist: in cache:\t\t") do
    (1..n).each do |i|
      Lawnchair::StorageEngine::Redis.exists?("redis_cache")
    end
  end
end

puts "*** Hash access vs. key access ***"

Lawnchair.redis.set("key_lookup", expensive_stuff.to_s)
Lawnchair.redis.hset("hash_lookup", "value", expensive_stuff.to_s)

Benchmark.bm(7) do |x|
  x.report("key: \t\t") do
    (1..n).each do |i|
      Lawnchair.redis.get("key_lookup")
    end
  end
  
  x.report("hash:\t\t") do
    (1..n).each do |i|
      Lawnchair.redis.hget("hash_lookup", "value")
    end
  end
end