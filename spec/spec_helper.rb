$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'lawnchair'
require 'spec'
require 'spec/autorun'
require 'redis'

Spec::Runner.configure do |config|
  config.before(:all)   { Lawnchair.connectdb(Redis.new(:db => 11)) }
  config.before(:each)  do 
    Lawnchair.flushdb
    base_store = Lawnchair::StorageEngine::Abstract
    base_store.cache_container.keys.each {|k| base_store.cache_container.delete(k)}
    
    in_process = Lawnchair::StorageEngine::InProcess
    in_process.cache_container.keys.each {|k| in_process.cache_container.delete(k)}
  end
end
