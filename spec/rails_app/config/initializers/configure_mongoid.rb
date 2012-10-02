if(TEKEYA_ORM == :mongoid)
  Mongoid.configure do |config|
    config.allow_dynamic_fields = false
    config.connect_to('tekeya_test')
  end
end