require 'erb'
require 'singleton'

module Tekeya
  # Parses the configuration file and holds important configuration attributes  
  class Configuration
    include Singleton
    
    attr_reader :redis, :rebat
    attr_accessor :redis_host, :redis_port, :rebatdb_host, :rebatdb_port, :feed_storage_orm
    
    # @private
    # Initializes a new configuration object
    def initialize
      parse_config      
      
      # Setup defaults
      @redis_host       ||= "localhost"
      @redis_port       ||= "6379"
      @rebatdb_host     ||= "localhost"
      @rebatdb_port     ||= "2011"
      @feed_storage_orm ||= :active_record

      setup_databases
    end

    def setup_databases
      # Setup redis
      @redis ||= Redis.new host: @redis_host, port: @redis_port.to_i

      # Setup rebatdb
      @rebat ||= Rebat.new "#{@rebatdb_host}", "#{@rebatdb_port}", { tracks: 1, joins: 2, blocks: 3 }
    end
    
    private    

    # Loads the configuration file
    # @return [nil]
    def parse_config      
      path = "#{Rails.root}/config/tekeya.yml"
      return unless File.exists?(path)
      
      conf = YAML::load(ERB.new(IO.read(path)).result)[Rails.env]
      
      conf.each do |key,value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end unless conf.nil?
    end
  end
end