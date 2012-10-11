require "slugable"
require "sqlite3"
require "ancestry"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load "db/schema.rb"

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

