class CranPackagesContributor< Sequel::Model
  many_to_one :contributor

  def find_by_cran_package_id_and_contributor(cran_package_id:, contributor_id:, role:)
    result = where(cran_package_id: cran_package_id, contributor_id: contributor_id).first
    Dry::Monads.Maybe(result)
  end
 
  def find_or_create(cran_package_id:, contributor_id:, role:)
    byebug
    find_by_cran_package_id_and_contributor(cran_package_id: cran_package_id, contributor_id: contributor_id, role: role)
    .value_or{
      begin
        create(cran_package_id: cran_package_id, contributor_id: contributor_id, role: role)
      rescue Sequel::Error => error
        record
      end
    }
  end
end


