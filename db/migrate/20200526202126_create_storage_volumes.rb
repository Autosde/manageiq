class CreateStorageVolumes < ActiveRecord::Migration[5.1]
  def change
    create_table :storage_volumes do |t|
      t.string :name
      t.boolean :compliant
      t.bigint :service_id
      t.bigint :size
      t.bigint :storage_resource_id
      t.bigint :storage_service_id
      t.string :uuid
      t.bigint :ems_id
      t.string :ems_ref

      t.timestamps
    end
  end
end
