class CranPackage < Sequel::Model
  many_to_many :dependencies
  one_to_many :cran_packages_contributors

  def get_contributors_by_package_and_role(role:)
    contributors = self.cran_packages_contributors.select{|cpc| cpc.role == role}
    contributors.empty? ? Dry::Monads::None() : Dry::Monads::Some(contributors)
  end

  def find_by_name_and_version(name:, version:)
    Dry::Monads::Maybe(where(name: name, version: version).first)
  end

  def find_or_create(**attrs)
    name = attrs[:name]
    version = attrs[:version]
    find_by_name_and_version(name: name, version: version)
      .value_or{
        begin
          create(**attrs)
        rescue Sequel::Error => error
          find_by_name_and_version(name: name, version: version)
        end
      }
  end
end
