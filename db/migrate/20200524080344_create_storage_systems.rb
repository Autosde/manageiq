class CreateStorageSystems < ActiveRecord::Migration[5.1]
  def change
    create_table :storage_systems do |t|
      t.string :management_ip
      t.string :name
      t.string :secondary_ip
      t.string :storage_array
      t.string :storage_family
      t.string :system_type
      t.string :uuid

      t.timestamps
    end
  end
end
