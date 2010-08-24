require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Fertilize
  attr_reader :size

  def initialize(size, key)
    @size = size
    @key = key
  end

  def self.primary_key
    :spread
  end

  def spread
    @key
  end
end

class Grass
  include ActiveRecord::LawnchairExtension
  attr_reader :length

  def initialize
    @length = 10
  end

  def kill
    @length = 0
  end

  def mow
    @length -= 1
  end

  def cut(how_much)
    @length -= how_much
  end

  def weed(puff, *args)
    @length -= puff.size
  end

  lawnchair_cache :mow
  lawnchair_cache :cut
  lawnchair_cache :weed, :expires_in => 0
end

describe "Lawnchair::Cache" do
  describe ".cache" do
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
    
    context "when in_process => true" do
      it "fetches the value to/from the composite store" do
        mock_composite_engine = Lawnchair::StorageEngine::Composite.new
        Lawnchair::StorageEngine::Composite.stub!(:new).and_return(mock_composite_engine)
        
        mock_composite_engine.should_receive(:fetch)
        Lawnchair.cache("mu", :in_process => true, :raw => true) { "fasa" }
      end
    end
    
    context "when there is content to be interpolated" do
      context "when the key exists in the cache" do
        before do 
          Lawnchair.cache("mu") { "current time: __TIME__" }
          Lawnchair.redis.exists("Lawnchair:mu").should be_true
        end
        
        it "replaces the key with the given data" do
          now = Time.now.to_s(:db)
          cached_result = Lawnchair.cache("mu", :interpolate => {"__TIME__" => now}) { "current time: __TIME__" }
          cached_result.should == "current time: #{now}"
        end
      end
      
      context "when the key does NOT exist in the cache" do
        before do 
          Lawnchair.redis.exists("mu").should be_false
        end
        
        it "replaces the key with the given data" do
          now = Time.now.to_s(:db)
          cached_result = Lawnchair.cache("mu", :interpolate => {"__TIME__" => now}) { "current time: __TIME__" }
          cached_result.should == "current time: #{now}"
        end
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

      describe "with parameters" do
        it "caches the value by parameter value as well" do
          grass = Grass.new
          grass.cut(2).should == 8
          grass.cut(1).should == 7
          grass.cut(3).should == 4

          grass.cut(1).should == 7
          grass.cut(2).should == 8
          grass.cut(3).should == 4

          grass.length.should == 4
        end
      end
      
      # describe "when the parameter is an ActiveRecord object" do
      #         before do
      #           @treatment1 = Fertilize.new(3, 'a')
      #           @treatment2 = Fertilize.new(3, 'b')
      #           @treatment3 = Fertilize.new(2, 'c')
      #           @treatment1_again = Fertilize.new(187, 'a')
      #           @grass = Grass.new
      #         end
      #         
      #         it "uses the primary key in the id" do
      #           @grass.weed(@treatment1).should == 7
      #           @grass.weed(@treatment2).should == 4
      #           @grass.weed(@treatment3).should == 2     
      #                
      #           @grass.weed(@treatment1).should == 7
      #           @grass.weed(@treatment2).should == 4          
      #           @grass.weed(@treatment3).should == 2          
      # 
      #           @grass.weed(@treatment1_again).should == 7
      #         end
      #       end
      
      # describe "when there are multiple parameters" do
      #   before do
      #     @treatment1 = Fertilize.new(3, 'a')
      #     @grass = Grass.new
      #   end
      #   
      #   it "takes all parameters into consideration" do
      #     @grass.weed(@treatment1, [1,2,3]).should == 7
      #     @grass.weed(@treatment1, [1,2]).should == 4
      #     @grass.weed(@treatment1, [1,2,3]).should == 7
      #     @grass.weed(@treatment1, [1,2]).should == 4
      #   end
      # end
      
      describe "when options are passed" do
        before do
          @treatment1 = Fertilize.new(3, 'a')
          @grass = Grass.new
        end
        
        it "allows the same options as regular calls to Lawnchair.cache" do
          @grass.weed(@treatment1, [1,2]).should == 7
          sleep 1
          @grass.weed(@treatment1, [1,2]).should == 4
        end
      end
    end
  end
end
