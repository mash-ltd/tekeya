require "tekeya/version"
require "tekeya/railtie"
require "active_support"

module Tekeya
  extend ActiveSupport::Autoload

  # Dependencies
  autoload :Redis, 'redis'
  autoload :Rebat, 'rebat'
  autoload :Resque, 'resque'
  # Modules
  autoload :Configuration
  autoload :Entity
  autoload :Group

  module Feed
    extend ActiveSupport::Autoload

    autoload :Activity
    autoload :Attachment

    module Resque
      extend ActiveSupport::Autoload

      autoload :ActivityFanout
    end
  end

  # Configure Tekeya
  #
  # Example::
  # 
  #   Tekeya.configure do |config|
  #     redis_host = "localhost"
  #     redis_port = 9200
  #     flockdb_host = 9200
  #     flockdb_port = 9200
  #   end
  def self.configure(&block)
    yield Tekeya::Configuration.instance
    Tekeya::Configuration.instance.setup_databases
  end

  def self.relations
    return Tekeya::Configuration.instance.rebat
  end

  def self.redis
    return Tekeya::Configuration.instance.redis
  end
end
