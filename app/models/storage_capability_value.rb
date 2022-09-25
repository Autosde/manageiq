class StorageCapabilityValue < ApplicationRecord

  belongs_to :storage_capability, :foreign_key => :capability_id, :dependent => :destroy
  has_and_belongs_to_many :physical_storage_family, join_table: "physical_storage_family_storage_capability_values"
  has_and_belongs_to_many :physical_storages, join_table: "physical_storages_storage_capability_values"
  has_and_belongs_to_many :storage_resources, join_table: "storage_capability_values_resources"
  has_and_belongs_to_many :cloud_volumes, join_table: "cloud_volumes_storage_capability_values"
  has_and_belongs_to_many :storage_services, join_table: "storage_capability_values_services"
end
