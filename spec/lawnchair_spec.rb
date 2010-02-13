require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lawnchair::Cache" do
  describe ".me" do
    it "raises an exception if no key is given" do
      lambda do
        Lawnchair::Cache.me("") { 1 }
      end.should raise_error
    end
    
    it "returns the value if it exists" do
      expected_object = [1,2,3,4]
      Lawnchair::Cache.me(:key => "marshalled_array") { expected_object }
      
      x = Lawnchair::Cache.me(:key => "marshalled_array") { "JUNK DATA" }
      x.should == expected_object
    end
    
    it "marshalls the object into redis" do
      expected_object = [1,2,3,4]
      Lawnchair::Cache.me("marshalled_array") { expected_object }
      
      Marshal.load(Lawnchair.redis["marshalled_array"]).should == [1,2,3,4]
    end
    
    describe "when in_process => true" do
      it "fetches the value to/from the composite store" do
        mock_composite_engine = Lawnchair::StorageEngine::Composite.new
        Lawnchair::StorageEngine::Composite.stub!(:new).and_return(mock_composite_engine)
        
        mock_composite_engine.should_receive(:fetch)
        Lawnchair::Cache.me("mu", :in_process => true, :raw => true) { "fasa" }
      end
    end
  end
end