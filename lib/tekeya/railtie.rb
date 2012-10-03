require "tekeya"
require "rails"

module Tekeya
  class Engine < ::Rails::Engine
    engine_name "tekeya"

    config.before_configuration do
      config.tekeya_orm = ::Tekeya::Configuration.instance.feed_storage_orm
      config.eager_load_paths.reject!{ |p| p =~ /\/app\/(\w+)$/ && !%w(controllers helpers views workers).include?($1) }
      config.autoload_paths += [ "#{config.root}/app/#{config.tekeya_orm}" ]
    end

    initializer "Configure Tekeya" do
      ::Tekeya::Configuration.instance.setup_databases
    end
  end
end
