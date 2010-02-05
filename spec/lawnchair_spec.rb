require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lawnchair::Cache" do
  describe ".please" do
    it "raises an exception if no key is given" do
      lambda do
        Lawnchair::Cache.please { 1 }
      end.should raise_error("Cache key please!")
    end
    
    context "when the object the block returns is a string" do
      it "returns the item from the cache if it exists" do
        Lawnchair::Cache.please(:key => "yogurt") { "strawberry/banana" }

        Lawnchair.redis["Lawnchair:yogurt"] = Marshal.dump("FROM THE CACHE")
        x = Lawnchair::Cache.please(:key => "yogurt") { "strawberry/banana" }
        x.should == "FROM THE CACHE"
      end
      
      it "sets the return value in the cache key given" do
        Lawnchair::Cache.please(:key => "pizza") { "muschroom/onion" }
        Lawnchair.redis["Lawnchair:pizza"].should == Marshal.dump("muschroom/onion")
      end
    end
    
    context "when the object the block returns is an object" do
      it "returns the value if it exists" do
        expected_object = [1,2,3,4]
        Lawnchair::Cache.please(:key => "marshalled_array") { expected_object }
        
        x = Lawnchair::Cache.please(:key => "marshalled_array") { "JUNK DATA" }
        x.should == expected_object
      end
      
      it "marshalls the object into redis" do
        expected_object = [1,2,3,4]
        Lawnchair::Cache.please(:key => "marshalled_array") { expected_object }
        
        Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3,4]
      end
    end
    
    it "sets a default ttl of 60 minutes" do
      Lawnchair::Cache.please(:key => "pizza") { "muschroom/onion" }
      Lawnchair.redis.ttl("Lawnchair:pizza").should == 3600 # seconds
    end
    
    it "allows you to override the default ttl" do
      Lawnchair::Cache.please(:key => "pizza", :expires_in => 1000) { "muschroom/onion" }
      Lawnchair.redis.ttl("Lawnchair:pizza").should == 1 # seconds
    end
  end
  
  describe ".exists?" do
    it "returns false when the key does not exist" do
      Lawnchair.redis.keys('*').should_not include("Lawnchair:mu")
      Lawnchair::Cache.exists?("mu").should be_false
    end
    
    it "returns true when the key exists" do
      Lawnchair.redis["Lawnchair:mu"] = "fasa"
      Lawnchair.redis.keys('*').should include("Lawnchair:mu")
      Lawnchair::Cache.exists?("mu").should be_true
    end
  end
end
