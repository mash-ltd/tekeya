require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'ruby-debug'

describe "Tekeya" do
  describe "Entity" do
    it "should inherit all the relations and feed methods" do
      # Public methods
      User.method_defined?(:track).should == true
      User.method_defined?(:tracking).should == true
      User.method_defined?(:"tracks?").should == true
      User.method_defined?(:untrack).should == true
      User.method_defined?(:block).should == true
      User.method_defined?(:blocked).should == true
      User.method_defined?(:"blocks?").should == true
      User.method_defined?(:unblock).should == true
      User.method_defined?(:join).should == true
      User.method_defined?(:groups).should == true
      User.method_defined?(:"member_of?").should == true
      User.method_defined?(:leave).should == true
      # Private methods
      User.private_method_defined?(:add_relation).should == true
      User.private_method_defined?(:delete_relation).should == true
      User.private_method_defined?(:relations_of).should == true
      User.private_method_defined?(:"relation_exists?").should == true
    end
  end

  describe "relations" do
    it "should add a new track relation" do
      debugger
    end
  end
end