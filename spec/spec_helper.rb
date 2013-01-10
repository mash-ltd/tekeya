require 'simplecov'
SimpleCov.start do 
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] = "test"
TEKEYA_ORM = (ENV["TEKEYA_ORM"] || :active_record).to_sym

require 'rspec'
require 'tekeya'
require 'bundler'

Bundler.require :default, :development, :test

require 'database_cleaner'
require "#{File.dirname(__FILE__)}/tekeya_helper"
require "#{File.dirname(__FILE__)}/../lib/tekeya"
require "#{File.dirname(__FILE__)}/rails_app/config/environment"
require "#{File.dirname(__FILE__)}/orm/#{TEKEYA_ORM}"
  
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  Fabrication.configure do |config|
    config.fabricator_path = 'fabricators'
    config.path_prefix = File.dirname(__FILE__)
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    Tekeya.relations.truncate
    Tekeya.redis.flushall
  end
  
  config.before(:all) do
   %w(tmp tmp/pids tmp/cache).each do |path|
      FileUtils.mkdir_p "#{Dir.pwd}/#{path}"
    end
  end

  REDIS_PID = File.join(File.dirname(__FILE__), '..', 'tmp','pids','redis-test.pid')
  REDIS_CACHE_PATH = File.join(File.dirname(__FILE__), '..', 'tmp','cache')

  config.before(:suite) do
    redis_options = {
      "daemonize"     => 'yes',
      "pidfile"       => REDIS_PID,
      "port"          => 9736,
      "timeout"       => 300,
      "save 900"      => 1,
      "save 300"      => 1,
      "save 60"       => 10000,
      "dbfilename"    => "dump.rdb",
      "dir"           => REDIS_CACHE_PATH,
      "loglevel"      => "debug",
      "logfile"       => "stdout",
      "databases"     => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`
  end

  config.after(:suite) do
    %x{
      cat #{REDIS_PID} | xargs kill -QUIT
      rm -f #{REDIS_CACHE_PATH}dump.rdb
    }

    FileUtils.rm_r "#{File.dirname(__FILE__)}/rails_app/db/test.sqlite3" rescue nil
  end
end