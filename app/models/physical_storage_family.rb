class PhysicalStorageFamily < ApplicationRecord
  include ProviderObjectMixin
  include SupportsFeatureMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id
  has_many   :physical_storages, :dependent => :nullify
  has_many   :storage_capability_value, foreign_key: true

  acts_as_miq_taggable
end
