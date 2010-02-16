require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lawnchair::Cache" do
  describe ".me" do
    it "returns the value if it exists" do
      expected_object = [1,2,3,4]
      Lawnchair.cache("marshalled_array") { expected_object }
      
      x = Lawnchair.cache("marshalled_array") { "JUNK DATA" }
      x.should == expected_object
    end
    
    it "marshalls the object into redis" do
      expected_object = [1,2,3,4]
      Lawnchair.cache("marshalled_array") { expected_object }
      
      Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3,4]
    end
    
    describe "when in_process => true" do
      it "fetches the value to/from the composite store" do
        mock_composite_engine = Lawnchair::StorageEngine::Composite.new
        Lawnchair::StorageEngine::Composite.stub!(:new).and_return(mock_composite_engine)
        
        mock_composite_engine.should_receive(:fetch)
        Lawnchair.cache("mu", :in_process => true, :raw => true) { "fasa" }
      end
    end
    
    describe ".connected?" do
      before do
        Lawnchair.stub!(:redis).and_return(nil)
      end
      
      context "when we have not established a connection to a redis server" do
        it "returns false" do
          Lawnchair.should_not be_connected
        end
      end
      
      context "when we have established a connection to a redis server" do
        attr_reader :redis
        before do
          @redis = Redis.new
          Lawnchair.stub!(:redis).and_return(redis)
        end
        
        context "when the redis server can be reached" do
          before do
            redis.stub(:info).and_return("something good")
          end
          
          it "returns true" do
            Lawnchair.should be_connected
          end
        end
        
        context "when the redis server can NOT be reached" do
          before do
            redis.stub(:info).and_raise("something bad")
          end
          
          it "returns false" do
            Lawnchair.should_not be_connected
          end
        end
      end
    end
  end
end