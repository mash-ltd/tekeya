unless defined?(TEKEYA_ORM)
  TEKEYA_ORM = (ENV["TEKEYA_ORM"] || :active_record).to_sym
end

require 'rubygems'
require 'bundler/setup'

$:.unshift File.expand_path('../../../../lib', __FILE__)