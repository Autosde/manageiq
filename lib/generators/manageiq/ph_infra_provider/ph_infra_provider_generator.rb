require_relative "../provider/provider_generator"

module ManageIQ
  class PhInfraProviderGenerator < ProviderGenerator
    source_root File.expand_path('templates', __dir__)

    private

    alias provider_name file_name

    def create_dummy
      template "app/models/%plugin_path%/physical_infra_manager/event_catcher/runner.rb"
      template "app/models/%plugin_path%/physical_infra_manager/event_catcher/stream.rb"
      template "app/models/%plugin_path%/physical_infra_manager/metrics_collector_worker/runner.rb"
      template "app/models/%plugin_path%/physical_infra_manager/refresh_worker/runner.rb"
      template "app/models/%plugin_path%/physical_infra_manager/event_catcher.rb"
      template "app/models/%plugin_path%/physical_infra_manager/metrics_capture.rb"
      template "app/models/%plugin_path%/physical_infra_manager/metrics_collector_worker.rb"
      template "app/models/%plugin_path%/physical_infra_manager/refresh_worker.rb"
      template "app/models/%plugin_path%/physical_infra_manager/refresher.rb"
      template "app/models/%plugin_path%/inventory/collector/physical_infra_manager.rb"
      template "app/models/%plugin_path%/inventory/parser/physical_infra_manager.rb"
      template "app/models/%plugin_path%/inventory/persister/definitions/physical_infra_collections.rb"
      template "app/models/%plugin_path%/inventory/persister/physical_infra_manager.rb"
      template "app/models/%plugin_path%/inventory/persister.rb"
      template "app/models/%plugin_path%/physical_infra_manager.rb"

      # MIQ codename ivanchuk requires updates for miq_worker_types.rb. In MIQ codename Jansa we dont need it.
      worker_file = Rails.root.join('lib/workers/miq_worker_types.rb')
      if File.exist?(worker_file)
        inject_into_file worker_file, <<~RB.indent(2), :after => "MIQ_WORKER_TYPES = {\n"
          "#{class_name}::PhysicalInfraManager::EventCatcher"                        => %i(manageiq_default),
          "#{class_name}::PhysicalInfraManager::RefreshWorker"                       => %i(manageiq_default),
        RB
      end

    end

  end
end
