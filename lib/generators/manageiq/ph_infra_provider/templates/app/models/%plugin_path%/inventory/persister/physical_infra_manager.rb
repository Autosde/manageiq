class <%= class_name %>::Inventory::Persister::PhysicalInfraManager < <%= class_name %>::Inventory::Persister
  include <%= class_name %>::Inventory::Persister::Definitions::PhysicalInfraCollections

  def initialize_inventory_collections
    initialize_physical_infra_inventory_collections
  end
end
