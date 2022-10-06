class StorageResourceCapabilityValue < ApplicationRecord
  # include ProviderObjectMixin  # TODO: needed?

  belongs_to :ext_management_system, :foreign_key => :ems_id
  belongs_to :storage_resource, :inverse_of => :storage_resource_capability_values
  belongs_to :storage_capability_value, :inverse_of => :storage_resource_capability_values

  # acts_as_miq_taggable  # TODO: needed?
end
