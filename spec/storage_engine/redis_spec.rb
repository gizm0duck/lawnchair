require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lawnchair::StorageEngine::RedisStore" do
  attr_reader :redis_store
  
  before do
    @redis_store = Lawnchair::StorageEngine::Redis
  end
  
  describe "#data_store" do
    it "returns the redis cache object" do
      Lawnchair.redis["Lawnchair:mu"] = "fasa"
      redis_store.data_store["Lawnchair:mu"].should == "fasa"
    end
  end
  
  describe "#set" do    
    it "sets a default ttl of 60 minutes" do
      redis_store.set("mu", "fasa")
      Lawnchair.redis.ttl("Lawnchair:mu").should == 3600 # seconds
    end
  
    it "allows you to override the default ttl" do
      redis_store.set("mu", "fasa", :expires_in => 600)
  
      Lawnchair.redis.ttl("Lawnchair:mu").should == 600 # seconds
    end
    
    context "when raw is true" do  
      it "sets the value in redis" do
        Lawnchair.redis["Lawnchair:mu"].should be_nil
        redis_store.set("mu", "fasa", :raw => true)
        Lawnchair.redis["Lawnchair:mu"].should == "fasa"
      end
    end
    
    context "when raw is false" do
      it "sets the value in redis" do
        value = "fasa"
        expected_value = Marshal.dump(value)
        
        Lawnchair.redis["Lawnchair:mu"].should be_nil
        redis_store.set("mu", value, :raw => false)
        Lawnchair.redis["Lawnchair:mu"].should == expected_value
      end
    end
  end
  
  describe "exists?" do
    it "returns false when the key does not exist" do
      Lawnchair.redis.keys('*').should_not include("Lawnchair:mu")
      redis_store.exists?("mu").should be_false
    end
  
    it "returns true when the key exists" do
      Lawnchair.redis["Lawnchair:mu"] = "fasa"
      Lawnchair.redis.keys('*').should include("Lawnchair:mu")
      redis_store.exists?("mu").should be_true
    end
  end
  
  describe "#expire!" do
    it "should only expire the key specified" do
      Lawnchair.redis["Lawnchair:mu"] = "fasa"
      Lawnchair.redis["Lawnchair:sim"] = "ba"
  
      redis_store.expire!("mu")
      Lawnchair.redis["Lawnchair:mu"].should be_nil
      Lawnchair.redis["Lawnchair:sim"].should == "ba"
    end
  end
end