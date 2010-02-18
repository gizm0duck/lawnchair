require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lawnchair::StorageEngine::InProcessStore" do
  attr_reader :in_process_store
  
  before do
    @in_process_store = Lawnchair::StorageEngine::InProcess
  end

  describe "#data_store" do
    it "returns the redis cache object" do
      Lawnchair::StorageEngine::InProcess.send(:class_variable_set, "@@data_store", {"Lawnchair:mu" => "fasa"})
      in_process_store.data_store["Lawnchair:mu"].should == "fasa"
    end
  end
  
  describe "#set" do
    context "when raw is true" do  
      it "sets the value" do
        in_process_store.data_store["Lawnchair:mu"].should be_nil
        in_process_store.set("mu", "fasa", :raw => true)
        in_process_store.data_store["Lawnchair:mu"].should == "fasa"
      end
    end
    
    context "when raw is false" do
      it "sets the value" do
        value = "fasa"
        expected_value = Marshal.dump(value)
        
        in_process_store.data_store["Lawnchair:mu"].should be_nil
        in_process_store.set("mu", value, :raw => false)
        in_process_store.data_store["Lawnchair:mu"].should == expected_value
      end
    end
  end
  
  describe "exists?" do
    it "returns false when the key does not exist" do
      in_process_store.data_store.keys.should_not include("Lawnchair:mu")
      in_process_store.exists?("mu").should be_false
    end

    it "returns true when the key exists" do
      in_process_store.data_store["Lawnchair:mu"] = "fasa"
      in_process_store.data_store.keys.should include("Lawnchair:mu")
      in_process_store.exists?("mu").should be_true
    end
  end
  
  describe "#expire!" do
    it "should only expire the key specified" do
      in_process_store.data_store["Lawnchair:mu"] = "fasa"
      in_process_store.data_store["Lawnchair:sim"] = "ba"

      in_process_store.expire!("mu")
      in_process_store.data_store["Lawnchair:mu"].should be_nil
      in_process_store.data_store["Lawnchair:sim"].should == "ba"
    end
  end
  
  describe "#db_connection?" do
    it "should return true" do
      in_process_store.should be_db_connection
    end
  end
end