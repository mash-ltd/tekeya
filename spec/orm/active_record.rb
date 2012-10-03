ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

ActiveRecord::Migrator.migrate(File.expand_path("../../rails_app/db/migrate/", __FILE__))
ActiveRecord::Migrator.migrate(File.expand_path("../../../db/migrate/", __FILE__))

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "active_record"
  end
end