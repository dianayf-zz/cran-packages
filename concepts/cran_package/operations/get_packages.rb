module CranPackages
  class GetPackages < Operation
    def initialize(
      get_packages_operation: Cran::GetPackages.new,
      find_or_create_package: CranPackages::FindOrCreatePackage.new
      ) 
      @get_packages_operation = get_packages_operation
      @find_or_create_package = find_or_create_package
      super
    end

    step :get_packages
    map :find_or_create_packages

    def get_packages(input)
      @get_packages_operation.call
       .bind(-> result {
         Success(packages: result)
       }) 
       .or{raise "packages can not retrieved"}
    end

    def find_or_create_packages(input)
      packages = input.fetch(:packages)[0..10]
      packages.map do |package|
        @find_or_create_package.call(package)
      end
    end

  end
end
