$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'lawnchair'
require 'spec'
require 'spec/autorun'
require 'redis'

Spec::Runner.configure do |config|
  config.before(:all)   { Lawnchair.connectdb(Redis.new(:db => 11)) }
  config.before(:each)  { Lawnchair.flushdb }
end
