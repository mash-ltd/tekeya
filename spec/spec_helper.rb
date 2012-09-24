$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] = "test"
TEKEYA_ORM = (ENV["TEKEYA_ORM"] || :active_record).to_sym

require 'rspec'
require 'tekeya'
require 'bundler'

Bundler.require :default, :development, :test

require "#{File.dirname(__FILE__)}/tekeya_helper"
require "#{File.dirname(__FILE__)}/../lib/tekeya"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  require 'database_cleaner'
  
  require "#{File.dirname(__FILE__)}/rails_app/config/environment"
  require "#{File.dirname(__FILE__)}/orm/#{TEKEYA_ORM}"
  
  config.before(:all) do
   %w(tmp tmp/config tmp/log).each do |path|
      FileUtils.mkdir_p "#{Dir.pwd}/#{path}"
    end
  end
  
  config.after(:all) do
    FileUtils.rm_r "#{Dir.pwd}/tmp" rescue nil
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end