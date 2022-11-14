class PhysicalStorageFamily < ApplicationRecord
  include ProviderObjectMixin
  include SupportsFeatureMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  has_many :physical_storages, :dependent => :nullify

  has_many :storage_family_capability_value_mappings, :inverse_of => :physical_storage_family, :dependent => :destroy
  has_many :storage_capability_values, :through => :storage_family_capability_value_mappings, :dependent => :destroy

  acts_as_miq_taggable
end
