require 'sequel'

Sequel::Model.raise_on_save_failure = false
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.db = Sequel.connect(ENV["DATABASE_URL"])

