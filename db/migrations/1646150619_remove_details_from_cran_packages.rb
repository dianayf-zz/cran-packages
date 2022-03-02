Sequel.migration do
  up do
    alter_table :cran_packages do
      add_column :title, String, text: true, null: false
      add_column :license, String, text: true, null: false
      add_column :r_version_needed, String, text: true
      drop_column :details
    end
  end
  down do
    alter_table :cran_packages do
      drop_column :title
      drop_column :license
      drop__column :r_version_needed
      add_column :details, "jsonb", text: true
    end
  end
end

