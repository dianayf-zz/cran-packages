Sequel.migration do
  change do
    create_table :cran_packages do
      primary_key :id
      column :name, String, text: true, null: false
      column :version, String, text: true, null: false
      column :details, "jsonb", text: true
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
    alter_table(:cran_packages) do
      add_unique_constraint [:name, :version]
    end
  end
end

