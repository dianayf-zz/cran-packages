class CranPackage < Sequel::Model
  def self.find_by_name_and_version(name:, version:)
    Dry::Monads::Maybe(where(name: name, version: version).first)
  end
end
