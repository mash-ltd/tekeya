if(TEKEYA_ORM == :mongoid)
  Mongoid.configure do |config|
    config.connect_to('tekeya_test')
  end
end
