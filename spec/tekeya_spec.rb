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
      Tekeya::Configuration.instance.feed_storage_orm.should == TEKEYA_ORM
    end

    describe "YML configuration" do
      before :all do
        conf_file = "#{File.dirname(__FILE__)}/../tmp/tekeya_config.yml"
        unless File.exists?(conf_file)
          f = File.new(conf_file, 'w')
          doc = %Q{
            test:
              redis_host: 'localhost'
              redis_port: '9736'
              rebatdb_host: 'localhost'
              rebatdb_port: '2011'
              feed_storage_orm: #{TEKEYA_ORM}
          }

          f.puts(doc)
          f.close
        end

        Tekeya::Configuration.instance.parse_config_file(conf_file)
      end

      it "should hold the correct data loaded from the yml" do
        Tekeya::Configuration.instance.redis_host.should == "localhost"
        Tekeya::Configuration.instance.redis_port.should == "9736"
        Tekeya::Configuration.instance.rebatdb_host.should == "localhost"
        Tekeya::Configuration.instance.rebatdb_port.should == "2011"
        Tekeya::Configuration.instance.feed_storage_orm.should == TEKEYA_ORM.to_s
      end
    end
  end
end
