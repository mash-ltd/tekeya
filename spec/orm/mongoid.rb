tekeya = TekeyaHelper.new
tekeya.setup_mongoid

config.before(:suite) do
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "mongoid"
end