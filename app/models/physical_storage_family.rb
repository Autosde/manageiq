class PhysicalStorageFamily < ApplicationRecord
  include ProviderObjectMixin
  include SupportsFeatureMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  has_many   :physical_storages, :dependent => :nullify
  has_and_belongs_to_many   :storage_capability_value, join_table: "physical_storage_family_storage_capability_values"

  acts_as_miq_taggable
end
