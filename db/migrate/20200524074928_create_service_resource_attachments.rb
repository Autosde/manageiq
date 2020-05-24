class CreateServiceResourceAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :service_resource_attachments do |t|
      t.string :storage_service_id
      t.string :storage_resource_id
      t.boolean :compliant
      t.string :uuid

      t.timestamps
    end
  end
end
