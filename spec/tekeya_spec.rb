require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tekeya" do
  describe "loading" do
    !(defined?(Rails).nil?).should == true
    !(defined?(ActiveRecord).nil?).should == true
    !(defined?(Mongoid).nil?).should == true
    !(defined?(Configuration).nil?).should == true
    !(defined?(Entity).nil?).should == true
    !(defined?(Entity::Group).nil?).should == true
  end
  
  describe "configuration" do
    it "should hold the correct data" do
      Tekeya::Configuration.instance.redis_host.should == "localhost"
      Tekeya::Configuration.instance.redis_port.should == "9736"
      Tekeya::Configuration.instance.rebatdb_host.should == "localhost"
      Tekeya::Configuration.instance.rebatdb_port.should == "2011"
    end
  end
end
