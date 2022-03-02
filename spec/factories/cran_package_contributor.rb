FactoryBot.define do
  factory :cran_packages_contributor do
    cran_package_id { 2 }
    contributor_id { 2 }
    role {Dependencies::RoleTypes::AUTHOR}
    created_at {Time.now}
    updated_at {Time.now}

    initialize_with do
      new(attributes)
    end
  end
end

