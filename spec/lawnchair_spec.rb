require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lawnchair::Cache" do
  describe ".please" do
    it "raises an exception if no key is given" do
      lambda do
        Lawnchair::Cache.please { 1 }
      end.should raise_error("Cache key please!")
    end
  end
end
