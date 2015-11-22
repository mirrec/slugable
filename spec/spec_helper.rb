puts ENV.inspect
if ENV['COVERAGE'] == '1'
  require 'simplecov'
  SimpleCov.start do
    load_profile 'test_frameworks'
    add_group 'Libraries", "lib'
  end
end

if ENV['CI'] == 'true'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'slugable'
require 'sqlite3'
require 'ancestry'
require 'pry'

ActiveRecord::Base.send :extend, Slugable::HasSlug

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

load 'db/schema.rb'

RSpec.configure do |config|
  config.filter_run focus: true
  config.filter_run_excluding skip: true
  config.run_all_when_everything_filtered = true

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

