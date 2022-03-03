module CranPackages
  class FindOrCreatePackage < Operation
    def initialize(
      get_package_info_operation: Cran::GetPackageInfo.new,
      package_repository: CranPackage,
      dependency_repository: Dependency,
      cran_package_dependency_repository: CranPackagesDependency,
      contributor_repository: Contributor,
      cran_package_contributor_repository: CranPackagesContributor
      ) 
      @get_package_info_operation = get_package_info_operation
      @package_repository = package_repository
      @dependency_repository = dependency_repository
      @cran_package_dependency_repository = cran_package_dependency_repository 
      @contributor_repository = contributor_repository
      @cran_package_contributor_repository = cran_package_contributor_repository
      super
    end

    step :get_info_package
    map :find_or_create_package
    map :create_dependencies
    map :create_authors
    map :create_maintainers

    def get_info_package(input)
      name = input.fetch(:name)
      p "CranPackages::FindOrCreatePackage - get_info_package: #{name}"
      version = input.fetch(:version)
      @get_package_info_operation.call(name: name, version: version)
       .bind(-> result {
         Success(input.merge(details: result))
       }) 
       .or{raise "package information can not retrieved"}
    end

    def find_or_create_package(input)
      p "CranPackages::FindOrCreatePackage - find_or_create_package"
      package_attrs = input.slice(:name, :version, :r_version_needed, :license)
        .merge(title: input.dig(:details,:title), publication_date: input.dig(:details,:publication_date))

      record = @package_repository.find_or_create(package_attrs).to_hash
      input.merge(package_record: record.to_hash)
    end

    def create_dependencies(input)
      p "CranPackages::FindOrCreatePackage - create_dependencies for package: #{input.fetch(:name)}"
      dependencies = input.fetch(:dependencies)
      package = input.fetch(:package_record)

      dependencies.each do |dependency|
        dependency_name = dependency.downcase.strip
        dependency = @dependency_repository.find_or_create(name: dependency_name).to_hash
        @cran_package_dependency_repository.find_or_create(cran_package_id: package.fetch(:id), dependency_id: dependency.fetch(:id))
      end
      input
    end

    def create_authors(input)
      p "CranPackages::FindOrCreatePackage - create_authors: #{input.fetch(:name)}"
      package = input.fetch(:package_record)
      authors = input.dig(:details, :authors)

      build_contributor_records_and_relations(contributors: authors, package: package, default_role: Contributors::CranRoleTypes::AUTH )
      input
    end

    def create_maintainers(input)
      p "CranPackages::FindOrCreatePackage - create_maintainers: #{input.fetch(:name)}"
      package = input.fetch(:package_record)
      maintainers = input.dig(:details, :maintainers)

      build_contributor_records_and_relations(contributors: maintainers, package: package, default_role: Contributors::CranRoleTypes::CRE )
      input.fetch(:package_record)
    end

    def build_contributor_records_and_relations(contributors:, package:, default_role:)
      contributors.each do |contributor|
        contributor_attrs = contributor.slice(:name, :email)
        record = @contributor_repository.find_or_create(contributor_attrs).to_hash
        roles = contributor[:role].empty? ? [default_role] : contributor[:role]

        roles.each do |role|
          role_name = Contributors::ROLE_CODE_INTERPRETER[role.downcase]
          @cran_package_contributor_repository.find_or_create(cran_package_id: package.fetch(:id),
                                                              contributor_id: record.fetch(:id),
                                                              role: role_name 
                                                              )
       end
      end
    end
  end
end
