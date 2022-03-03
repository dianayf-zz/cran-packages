class CranPackagesDependency < Sequel::Model
  def find_by_cran_package_id_and_dependency(cran_package_id:, dependency_id:)
    result = where(cran_package_id: cran_package_id, dependency_id: dependency_id).first
    Dry::Monads.Maybe(result)
  end
 
  def find_or_create(cran_package_id:, dependency_id:)
    find_by_cran_package_id_and_dependency(cran_package_id: cran_package_id, dependency_id: dependency_id)
    .value_or{
      begin
        create(cran_package_id: cran_package_id, dependency_id: dependecy_id)
      rescue Sequel::Error => error
        record
      end
    }
  end
end


