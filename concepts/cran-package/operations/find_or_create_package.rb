module CranPackages
  class FindOrCreatePackage < Operation
    def initialize(
      get_package_info_operation: Cran::GetPackageInfo.new,
      package_repository: CranPackageRepository.new
      ) 
      @get_package_info_operation = get_package_info_operation
      @package_repository = package_repository
      super
    end

    step :get_info_package
    map :find_or_create_package

    def get_info_package(input)
      name = input.fetch(:name)
      version = input.fetch(:version)
      @get_package_info_operation.call(name: name, version: version)
       .bind(-> result {
         Success(input.merge(details: result))
       }) 
       .or{raise "package information can not retrieved"}
    end

    def find_or_create_package(input)
      name = input.fetch(:name)
      version = input.fetch(:version)
      details = input.fetch(:details)
      @package_repository.find_or_create(name: name, version: version, details: details)
    end

  end
end
