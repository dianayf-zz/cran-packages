Sequel.migration do
  change do
    create_table :cran_packages_contributors do
      primary_key :id
      column :contributor_id, Integer, text: true
      column :cran_package_id, Integer, text: true
      column :role, String, text: true
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
      foreign_key [:cran_package_id], :cran_packages
      foreign_key [:contributor_id], :contributors
    end
  end
end

