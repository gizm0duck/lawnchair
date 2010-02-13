require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lawnchair::StorageEngine::Abstract" do
  attr_reader :base_store
  
  before do
    @base_store = Lawnchair::StorageEngine::Abstract
  end
  
  describe ".cache_container" do
    it "should be an empty hash" do
      base_store.cache_container.should == {}
    end
  end
  
  describe ".fetch" do
    context "when key exists" do
      before do
        base_store.stub!(:exists?).and_return(true)
        base_store.cache_container["sim"] = "ba"
      end
      
      it "returns the value from the cache" do
        value = base_store.fetch("sim", :raw => true) { "DOESNT MATTER" }
        value.should == "ba"
      end
    end
    
    context "when key does not exist" do
      before do
        base_store.stub!(:exists?).and_return(false)
        base_store.cache_container["sim"].should be_nil
        
        class Lawnchair::StorageEngine::Abstract
          def self.set(key, value, options={})
            cache_container[key] = value
          end
        end
      end
      
      it "computes the value and saves it to the cache" do
        value = base_store.fetch("sim", :raw => true) { "ba" }
        base_store.cache_container["sim"].should == "ba"
      end
    end
  end
  
  describe ".get" do
    context "when raw is true" do
      it "gets the value in key if it exists" do
        base_store.cache_container["mu"] = "fasa"
        base_store.get("mu", :raw => true).should == "fasa"
      end
      
      it "returns nil if the key does not exist" do
        base_store.cache_container["mu"].should be_nil
        base_store.get("mu", :raw => true).should be_nil
      end
    end
    
    context "when raw is false" do
      context "when they key exists" do
        before do
          base_store.stub!(:exists?).and_return(true)
        end
        
        it "gets the value in key if it exists and unmarshalls it" do
          expected_value = "fasa"
          value = Marshal.dump(expected_value)

          base_store.cache_container["mu"] = value
          base_store.get("mu", :raw => false).should == expected_value
        end
      end
      
      context "when the key does not exist" do
        before do
          base_store.stub!(:exists?).and_return(false)
        end
        
        it "returns nil if the key does not exist" do
          base_store.cache_container["mu"].should be_nil
          base_store.get("mu", :raw => false).should be_nil
        end
      end
    end
  end
  
  describe ".compute_key" do
    it "should prepend keys with Lawnchair:" do
      Lawnchair::StorageEngine::Abstract.compute_key("hooo").should == "Lawnchair:hooo"
    end
  end
end