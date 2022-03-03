FactoryBot.define do
  factory :cran_packages_dependency do
    cran_package_id { 2 }
    dependency_id { 2 }
    created_at {Time.now}
    updated_at {Time.now}

    initialize_with do
      new(attributes)
    end
  end
end

