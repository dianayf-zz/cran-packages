require "dry-validation"
class AppSchema < Dry::Validation::Contract
  config.messages.default_locale = :es
  config.messages.load_paths << 'config/errors.yml'
end
