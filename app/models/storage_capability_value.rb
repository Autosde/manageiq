class StorageCapabilityValue < ApplicationRecord
  include NewWithTypeStiMixin
  include ProviderObjectMixin
  include SupportsFeatureMixin
  include CustomActionsMixin
  include EmsRefreshMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  belongs_to :storage_capability, :foreign_key => :storage_capability_id

  acts_as_miq_taggable

  def self.class_by_ems(ext_management_system)
    ext_management_system&.class_by_ems(:StorageResource)
  end
end
