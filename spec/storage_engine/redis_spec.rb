require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lawnchair::StorageEngine::RedisStore" do
  attr_reader :redis_store
  
  before do
    @redis_store = Lawnchair::StorageEngine::Redis
  end
  
  describe "#cache_container" do
    it "returns the redis cache object" do
      Lawnchair.redis["mu"] = "fasa"
      redis_store.cache_container["mu"].should == "fasa"
    end
  end
  
  describe "#set" do    
    it "sets a default ttl of 60 minutes" do
      redis_store.set("mu", "fasa")
      Lawnchair.redis.ttl("mu").should == 3600 # seconds
    end

    it "allows you to override the default ttl" do
      redis_store.set("mu", "fasa", :expires_in => 600)
      Lawnchair.redis.ttl("mu").should == 600 # seconds
    end
    
    context "when raw is true" do  
      it "sets the value in redis" do
        Lawnchair.redis["mu"].should be_nil
        redis_store.set("mu", "fasa", :raw => true)
        Lawnchair.redis["mu"].should == "fasa"
      end
    end
    
    context "when raw is false" do
      it "sets the value in redis" do
        value = "fasa"
        expected_value = Marshal.dump(value)
        
        Lawnchair.redis["mu"].should be_nil
        redis_store.set("mu", value, :raw => false)
        Lawnchair.redis["mu"].should == expected_value
      end
    end
  end
  
  describe "exists?" do
    it "returns false when the key does not exist" do
      Lawnchair.redis.keys('*').should_not include("mu")
      redis_store.exists?("mu").should be_false
    end

    it "returns true when the key exists" do
      Lawnchair.redis["mu"] = "fasa"
      Lawnchair.redis.keys('*').should include("mu")
      redis_store.exists?("mu").should be_true
    end
  end
  
  describe "#expire!" do
    it "should only expire the key specified" do
      Lawnchair.redis["mu"] = "fasa"
      Lawnchair.redis["sim"] = "ba"

      redis_store.expire!("mu")
      Lawnchair.redis["mu"].should be_nil
      Lawnchair.redis["sim"].should == "ba"
    end
  end
end