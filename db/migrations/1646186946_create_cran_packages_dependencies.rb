Sequel.migration do
  change do
    create_table :cran_packages_dependencies do
      primary_key :id
      column :cran_package_id, Integer, text: true
      column :dependency_id, Integer, text: true
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
      foreign_key [:cran_package_id], :cran_packages
      foreign_key [:dependency_id], :dependencies
    end
  end
end

