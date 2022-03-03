module CranPackages
  class Index < Operation
    PACKAGE_ATTRIBUTES = [:name, :version, :title, :license, :r_version_needed, :publication_date].freeze

    def initialize(
      cran_package_repository: CranPackage
      ) 
      @cran_package_repository = cran_package_repository
      super
    end

    map :get_packages
    map :serialize

    def get_packages(input)
      {packages: @cran_package_repository.all}
    end

    def serialize(input)
      packages = input.fetch(:packages)
      packages.map do |package|
        package_hash = package.to_hash
        package_serialized = serialize_basic_info_package(package_hash)
        package_serialized.merge(
          dependencies: serialize_dependencies(package),
          authors: serialize_contributors_by_role(package: package, role: Contributors::RoleTypes::AUTHOR),
          maintainers: serialize_contributors_by_role(package: package, role: Contributors::RoleTypes::MAINTAINER)
        )
      end
    end

    def serialize_basic_info_package(package)
      PACKAGE_ATTRIBUTES.inject({}) do |new_package_data, key|
        new_package_data[key] = package[key]
        new_package_data
      end
    end

    def serialize_dependencies(package)
      package.dependencies.map{|dependency| dependency.to_hash.slice(:name)}
    end

    def serialize_contributors_by_role(package:, role:)
       result = package.get_contributors_by_package_and_role(role: role )
        .bind(-> cran_packages_contributors {
          Success(
            cran_packages_contributors.map do |cpc|
              {name: cpc.contributor.name , role: cpc.role }
            end
          )
        }).value_or([])
    end
  end
end
