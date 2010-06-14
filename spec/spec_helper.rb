$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lawnchair'
require 'spec'
require 'spec/autorun'
require 'active_record_extension'
Spec::Runner.configure do |config|
  config.before(:all)   { Lawnchair.connectdb(Redis.new(:db => 11)) }
  config.before(:each)  do 
    Lawnchair.flushdb
    abstract_store = Lawnchair::StorageEngine::Abstract
    abstract_store.data_store.keys.each {|k| abstract_store.data_store.delete(k)}
    
    in_process = Lawnchair::StorageEngine::InProcess
    in_process.data_store.keys.each {|k| in_process.data_store.delete(k)}
  end
end
