# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})

  watch('spec/spec_helper.rb')  { "spec" }

  watch('lib/tekeya.rb') { "spec/tekeya_spec.rb" }
  watch('lib/tekeya/configuration.rb') { "spec/tekeya_spec.rb" }
  watch('lib/tekeya/railtie.rb') { "spec/tekeya_spec.rb" }

  watch('lib/tekeya/entity.rb') { "spec/tekeya/entity_spec.rb" }
  watch(%r{^lib/tekeya/entity/.+\.rb$}) { "spec/tekeya/entity_spec.rb" }

  watch(%r{^lib/tekeya/feed/.+\.rb$}) { "spec/tekeya/feed_spec.rb" }
  watch(%r{^lib/tekeya/feed/resque/.+\.rb$}) { "spec/tekeya/feed_spec.rb" }
end


guard 'rspec', :env => {'TEKEYA_ORM' => 'mongoid'} do
  watch(%r{^spec/.+_spec\.rb$})

  watch('spec/spec_helper.rb')  { "spec" }

  watch('lib/tekeya.rb') { "spec/tekeya_spec.rb" }
  watch('lib/tekeya/configuration.rb') { "spec/tekeya_spec.rb" }
  watch('lib/tekeya/railtie.rb') { "spec/tekeya_spec.rb" }

  watch('lib/entity.rb') { "spec/tekeya/entity_spec.rb" }
  watch(%r{^lib/tekeya/entity/.+\.rb$}) { "spec/tekeya/entity_spec.rb" }

  watch(%r{^lib/tekeya/feed/.+\.rb$}) { "spec/tekeya/feed_spec.rb" }
  watch(%r{^lib/tekeya/feed/resque/.+\.rb$}) { "spec/tekeya/feed_spec.rb" }
end