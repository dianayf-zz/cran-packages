class CranPackage < Sequel::Model
  def self.find_by_name_and_version(name:, version:)
    Dry::Monads::Maybe(where(name: name, version: version).first)
  end

  def self.find_or_create(**attrs)
    name, version, details = attrs.slice(:name, :version, :details)
    find_by_name_and_version(name: name, version: version)
      .value_or{
        begin
          create(**attrs)
        rescue  Sequel::Model::Error => error
          find_by_name_and_version(name: name, version: version)
        end
      }
  end
end
