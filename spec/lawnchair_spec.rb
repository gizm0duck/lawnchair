require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Grass

  def initialize
    @length = 10
  end

  def id
    object_id
  end

  def kill
    @length = 0
  end

  def mow
    @length -= 1
  end

  lawnchair_cache :mow
end

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
    
    describe "caching a method" do
      it "should cache the value of a method" do
        grass = Grass.new
        grass.mow.should == 9
        grass.mow.should == 9
      end

      it "should cache a unique value per instance" do
        grass = Grass.new
        weed = Grass.new
        weed.kill
        grass.mow.should == 9
        grass.mow.should == 9
        weed.mow.should == -1
        weed.mow.should == -1
      end
    end
  end
end
