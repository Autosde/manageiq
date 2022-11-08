class StorageServiceCapabilityValueMapping < ApplicationRecord
  include NewWithTypeStiMixin
  include ProviderObjectMixin
  include SupportsFeatureMixin
  include CustomActionsMixin
  include EmsRefreshMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  belongs_to :storage_service, :inverse_of => :storage_service_capability_value_mapping
  belongs_to :storage_capability_value, :inverse_of => :storage_service_capability_value_mapping

  acts_as_miq_taggable

  def self.class_by_ems(ext_management_system)
    ext_management_system&.class_by_ems(:StorageServiceCapabilityValueMapping)
  end
end
