module CranPackages
  class UpdatePackagesInfo < Operation
    def initialize(
      get_packages_operation: Cran::GetPackages.new,
      get_package_info_operation: Cran::GetPackageInfo.new,
      package_repository: CranPackageRepository.new
      ) 
      @get_packages_operation = get_packages_operation
      @get_package_info_operation = get_package_info_operation
      @package_repository = package_repository
      super
    end

    step :get_packages
    map :get_info_package
    step :persit_data

    def get_packages(input)
      @get_packages_operation.call
         .bind(-> result { input.merge(packages: result) })
         .or{raise "packages information can not retrieved"}
    end

    def get_info_package(input)
      input.fetch(:packages).each do |package|
          name = package.fetch(:package_name)
          version = package.fetch(:version)
          @get_package_info_operation.call(name: name, version: version)
           .bind(-> result {
             @package_repository.find_by_name_and_version(name: name, version: version)
             .fmap(-> package_record {
               updatable_attributes = result.except([:package_name, :version])
               @package_repository.update(package_record.id, updatable_attributes)
             })
           }) 
           .or{raise "package information can not updated"}
      end
    end

  end
end
