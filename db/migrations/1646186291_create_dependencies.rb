Sequel.migration do
  change do
    create_table :dependencies do
      primary_key :id
      column :name, String, text: true, null: false
    end
  end
end

