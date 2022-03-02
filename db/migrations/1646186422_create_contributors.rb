Sequel.migration do
  change do
    create_table :contributors do
      primary_key :id
      column :name, String, text: true, null: false
      column :email, String, text: true, null: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
    alter_table(:contributors) do
      add_unique_constraint [:name, :email]
    end
  end
end

