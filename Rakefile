require 'rake'
require 'rake/testtask'

task :env do
  require_relative 'boot'
end

task console: :env do
  pry
end

task default: :test
task spec: :test

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(ENV.fetch("DATABASE_URL")) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
      puts "Migrating to latest"
    end
  end
end
