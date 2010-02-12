require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lawnchair::Cache" do
  describe ".me" do
    it "raises an exception if no key is given" do
      lambda do
        Lawnchair::Cache.me { 1 }
      end.should raise_error("Cache key please!")
    end
    
    it "returns the value if it exists" do
      expected_object = [1,2,3,4]
      Lawnchair::Cache.me(:key => "marshalled_array") { expected_object }
      
      x = Lawnchair::Cache.me(:key => "marshalled_array") { "JUNK DATA" }
      x.should == expected_object
    end
    
    it "marshalls the object into redis" do
      expected_object = [1,2,3,4]
      Lawnchair::Cache.me(:key => "marshalled_array") { expected_object }
      
      Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3,4]
    end
    
    describe "when passed :force => true" do
      it "expires the key and sets it to the new return value" do
        initial_expected_object = [1,2,3,4]
        new_expected_object     = [1,2,3]
        Lawnchair::Cache.me(:key => "marshalled_array") { initial_expected_object }
        Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3,4]
        
        Lawnchair::Cache.me(:key => "marshalled_array", :force => true) { new_expected_object }
        Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3]
      end
    end
    
    describe "when in_process => true" do
      describe "when the value does not exist in redis" do
        it "should set the value to the key in process as well as in redis" do
          expected_object = [1,2,3,4]
          Lawnchair::Cache.me(:key => "marshalled_array", :in_process => true) { expected_object }
          Marshal.load(Lawnchair.redis["Lawnchair:marshalled_array"]).should == [1,2,3,4]
          Marshal.load(Lawnchair::Cache.in_process_store["Lawnchair:marshalled_array"]).should == [1,2,3,4]
        end
      end
      
      describe "when the value exists in redis" do
        it "takes the value from redis and places it in the in process cache" do
          expected_object = [1,2,3,4]
          unexpected_object = [1,2,3,4,5,6,7,8]
          Lawnchair::Cache.me(:key => "marshalled_array") { expected_object }
          Lawnchair::Cache.in_process_store["Lawnchair:marshalled_array"].should be_nil
          Lawnchair::Cache.me(:key => "marshalled_array", :in_process => true) { unexpected_object }
          Marshal.load(Lawnchair::Cache.in_process_store["Lawnchair:marshalled_array"]).should == expected_object
        end
      end
    end
    
    it "sets a default ttl of 60 minutes" do
      Lawnchair::Cache.me(:key => "pizza") { "muschroom/onion" }
      Lawnchair.redis.ttl("Lawnchair:pizza").should == 3600 # seconds
    end
    
    it "allows you to override the default ttl" do
      Lawnchair::Cache.me(:key => "pizza", :expires_in => 1) { "muschroom/onion" }
      Lawnchair.redis.ttl("Lawnchair:pizza").should == 1 # seconds
    end
  end
  
  describe ".exists?" do
    context "when :in_process = true" do
      it "returns false when the key does not exist" do
        Lawnchair::Cache.in_process_store["Lawnchair:mu"].should be_nil
        Lawnchair::Cache.exists?("mu", true).should be_false
      end

      it "returns true when the key exists" do
        Lawnchair::Cache.in_process_store["Lawnchair:mu"] = "fasa"
        Lawnchair::Cache.exists?("mu", true).should be_true
      end
    end
    
    context "when :in_process = false" do
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
  
  describe ".expire" do
    it "should only expire the key specified in redis" do
      Lawnchair.redis["Lawnchair:mu"] = "fasa"
      Lawnchair.redis["Lawnchair:sim"] = "ba"
    
      Lawnchair::Cache.expire("mu")
      Lawnchair.redis["Lawnchair:mu"].should be_nil
      Lawnchair.redis["Lawnchair:sim"].should == "ba"
    end
    
    it "expires the in_process key" do
      Lawnchair::Cache.in_process_store["Lawnchair:mu"] = "fasa"
      Lawnchair::Cache.in_process_store["Lawnchair:sim"] = "ba"
    
      Lawnchair::Cache.expire("mu")
      Lawnchair::Cache.in_process_store["Lawnchair:mu"].should be_nil
      Lawnchair::Cache.in_process_store["Lawnchair:sim"].should == "ba"
    end
  end
end