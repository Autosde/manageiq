class StorageCapability < ApplicationRecord
  belongs_to :ext_management_system, :foreign_key => :ems_id, :inverse_of => storage_capability
end
