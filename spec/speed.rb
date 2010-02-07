require 'benchmark'
require "#{File.dirname(__FILE__)}/../lib/lawnchair"

Lawnchair.redis.flushdb

# Totally contrived and fairly useless example... just wanted to make sure the overhead of 
# reading and marshalling the data isn't obscene

# *** Performing 1000 iterations ***
#              user       system        total        real
# cached:     0.140000    0.040000    0.180000    ( 0.292324)
# not cached: 26.070000   0.620000    26.690000   ( 27.156388)

n = (ARGV.shift || 1000).to_i

puts "*** Performing #{n} iterations ***"

def expensive_stuff
  a = []
  100.times do
    a << Date.parse("Dec 3. 1981")
  end
end

Benchmark.bm(7) do |x|
  x.report("cached:") do
    (1..n).each do |i|
      Lawnchair::Cache.me(:key => "foo") do
        expensive_stuff
      end
    end
  end
  
  x.report("not cached:") do
    (1..n).each do |i|
      expensive_stuff
    end
  end
end
