Tekeya.configure do |config|
  config.redis_host       = "localhost"
  config.redis_port       = "9736"
  config.rebatdb_host     = "localhost"
  config.rebatdb_port     = "2011"
  config.feed_storage_orm = TEKEYA_ORM
end