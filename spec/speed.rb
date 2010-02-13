require 'benchmark'
require "#{File.dirname(__FILE__)}/../lib/lawnchair"

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
  100.times do
    a << Date.parse("Dec 3. 1981")
  end
end

Benchmark.bm(7) do |x|
  x.report("cached:\t\t") do
    (1..n).each do |i|
      Lawnchair::Cache.me("redis_cache") do
        expensive_stuff
      end
    end
  end
  
  x.report("in process cached:") do
    (1..n).each do |i|
      Lawnchair::Cache.me("in_process_cache", :in_process => true) do
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