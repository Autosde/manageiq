class StorageCapabilityValue < ApplicationRecord
  belongs_to :storage_capability, :foreign_key => :capability_id
end
