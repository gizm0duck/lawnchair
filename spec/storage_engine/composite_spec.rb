require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lawnchair::StorageEngine::Composite" do
  attr_reader :composite_store
  
  before do
    @composite_store = Lawnchair::StorageEngine::Composite.new
  end
  
  describe "initialization" do
    it "has a collection of storage_engines" do
      composite_store.storage_engines == []
    end
    
    it "allows you to specify storage engines" do
      composite_store = Lawnchair::StorageEngine::Composite.new(:in_process, :redis)
      composite_store.storage_engines.should == [Lawnchair::StorageEngine::InProcess, Lawnchair::StorageEngine::Redis]
    end
  end
  
  describe "#register_storage_engine" do
    before do
      composite_store.storage_engines.should be_empty
    end
    
    it "adds a storage engine to the collection" do
      composite_store.register_storage_engine :redis
      composite_store.storage_engines.should == [Lawnchair::StorageEngine::Redis]
    end
  end
  
  describe "#fetch" do
    context "when no storage engines have been configured" do
      it "raises an exception" do
        lambda do
          composite_store.fetch("key", {}) {x=1}
        end.should raise_error("No Storage Engines Configured")
      end
    end
    
    context "when there is only 1 storage engine" do
      before do
        composite_store.register_storage_engine :redis
      end
      
      context "when the key does not exist" do
        it "sets the value on the key in the storage engine specified" do
          Lawnchair.redis["Lawnchair:mu"].should be_nil
          composite_store.fetch("mu", {:raw => true}) { "fasa" }
          Lawnchair.redis["Lawnchair:mu"].should == "fasa"
        end
      end
      
      context "when the key exists" do
        before do
          Lawnchair.redis["Lawnchair:sim"] = "ba"
        end
        
        it "returns the value in the key from the storage engine specified" do
          value = composite_store.fetch("sim", {:raw => true}) { "DOESNT MATTER" }
          value.should == "ba"
        end
      end
    end
    
    context "when there are two storage engines" do
      before do
        @composite_store = Lawnchair::StorageEngine::Composite.new(:in_process, :redis)
      end
      
      context "when the key exists in the first storage engine" do
        before do
          Lawnchair::StorageEngine::InProcess.set("mu", "fasa", :raw => true)
          Lawnchair::StorageEngine::Redis.get("mu").should be_nil
        end
        
        it "returns the value from the first storage engine" do
          value = composite_store.fetch("mu", {:raw => true}) { "DOESNT MATTER" }
          value.should == "fasa"
        end
      end
      
      context "when the key exists in the second storage engine but not the first" do
        before do
          Lawnchair::StorageEngine::InProcess.get("mu").should be_nil
          Lawnchair::StorageEngine::Redis.set("mu", "fasa", :raw => true)
        end
        
        it "places the value in the first storage engine" do
          composite_store.fetch("mu", {:raw => true}) { "DOESNT MATTER" }.should == "fasa"
          Lawnchair::StorageEngine::InProcess.get("mu", :raw => true).should == "fasa"
        end
      end
      
      context "when the key doesnt exist in either storage engine" do
        before do
          Lawnchair::StorageEngine::InProcess.get("mu").should be_nil
          Lawnchair::StorageEngine::Redis.get("mu").should be_nil
        end
        
        it "sets the value in both storage engines" do
          composite_store.fetch("mu", {:raw => true}) { sleep 0.2; "fasa" }
          Lawnchair::StorageEngine::InProcess.get("mu", :raw => true).should == "fasa"
          Lawnchair::StorageEngine::Redis.get("mu", :raw => true).should == "fasa"
        end
        
        it "only calls the block 1 time for both engines" # spec should take less than .4 seconds to run
      end
    end
  end
  
end