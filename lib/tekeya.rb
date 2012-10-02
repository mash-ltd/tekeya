require "tekeya/version"
require "tekeya/railtie"
require "active_support"

module Tekeya
  extend ActiveSupport::Autoload

  # Dependencies
  autoload :Redis, 'redis'
  autoload :Rebat, 'rebat'
  # Modules
  autoload :Configuration
  autoload :Entity
  autoload :Group
  autoload :Activity, 'tekeya/feed/activity'
  autoload :Attachement, 'tekeya/feed/attachement'

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
  end

  def self.relations
    return Tekeya::Configuration.instance.rebat
  end
end
