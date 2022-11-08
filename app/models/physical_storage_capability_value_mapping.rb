class PhysicalStorageCapabilityValueMapping < ApplicationRecord
  include NewWithTypeStiMixin
  include ProviderObjectMixin
  include SupportsFeatureMixin
  include CustomActionsMixin
  include EmsRefreshMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  belongs_to :physical_storage, :inverse_of => :physical_storage_capability_values
  belongs_to :storage_capability_value, :inverse_of => :physical_storage_capability_values

  acts_as_miq_taggable

  def self.class_by_ems(ext_management_system)
    ext_management_system&.class_by_ems(:PhysicalStorageCapabilityValueMapping)
  end
end
