class <%= class_name %>::PhysicalInfraManager::EventCatcher < ManageIQ::Providers::BaseManager::EventCatcher
  require_nested :Runner
end
