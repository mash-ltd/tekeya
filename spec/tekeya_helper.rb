class TekeyaHelper  
  def initialize(redis_host="localhost", redis_port="6379",
                 rebatdb_host="localhost", rebatdb_port="2011")

    Tekeya.configure do |config|
      config.redis_host    = redis_host
      config.redis_port    = redis_port
      config.rebatdb_host  = rebatdb_host
      config.rebatdb_port  = rebatdb_port
    end
  end
  
  def setup_mongoid
    Mongoid.configure do |config|
      name = "Tekeya"
      host = "localhost"
      username = ""
      password = ""
      config.allow_dynamic_fields = false
      config.master = Mongo::Connection.new.db(name)        
    end
  end  
end