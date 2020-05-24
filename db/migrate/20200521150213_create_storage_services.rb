class CreateStorageServices < ActiveRecord::Migration[5.1]
  def change
    create_table :storage_services do |t|
      t.string :name
      t.string :description
      t.string :project_id
      t.string :profile_id
      t.string :uuid
      t.bigint :version
      t.string :parent_service_id
      t.string :capability_values

      t.timestamps
    end
  end
end
