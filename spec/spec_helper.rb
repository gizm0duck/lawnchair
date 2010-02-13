$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lawnchair'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before(:all)   { Lawnchair.connectdb(Redis.new(:db => 11)) }
  config.before(:each)  do 
    Lawnchair.flushdb
    abstract_store = Lawnchair::StorageEngine::Abstract
    abstract_store.cache_container.keys.each {|k| abstract_store.cache_container.delete(k)}
    
    in_process = Lawnchair::StorageEngine::InProcess
    in_process.cache_container.keys.each {|k| in_process.cache_container.delete(k)}
  end
end
