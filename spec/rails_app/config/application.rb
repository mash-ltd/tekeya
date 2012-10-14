require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

Bundler.require :default, :development

begin
  require "#{TEKEYA_ORM}/railtie"
rescue LoadError
end

require "tekeya"

module RailsApp
  class Application < Rails::Application
    # Add additional load paths for your own custom dirs
    config.eager_load_paths.reject!{ |p| p =~ /\/app\/(\w+)$/ && !%w(controllers helpers views).include?($1) }
    config.autoload_paths += [ "#{config.root}/app/#{TEKEYA_ORM}" ]

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
    config.assets.enabled = false

    config.action_mailer.default_url_options = { :host => "localhost:3000" }
  end
end
