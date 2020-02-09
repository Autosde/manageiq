require_relative "../provider/provider_generator"

module ManageIQ
  class CloudProviderGenerator < ProviderGenerator
    source_root File.expand_path('templates', __dir__)

    private

    alias provider_name file_name

    def create_dummy
      template "app/models/%plugin_path%/cloud_manager/event_catcher/runner.rb"
      template "app/models/%plugin_path%/cloud_manager/event_catcher/stream.rb"
      template "app/models/%plugin_path%/cloud_manager/metrics_collector_worker/runner.rb"
      template "app/models/%plugin_path%/cloud_manager/refresh_worker/runner.rb"
      template "app/models/%plugin_path%/cloud_manager/event_catcher.rb"
      template "app/models/%plugin_path%/cloud_manager/metrics_capture.rb"
      template "app/models/%plugin_path%/cloud_manager/metrics_collector_worker.rb"
      template "app/models/%plugin_path%/cloud_manager/refresh_worker.rb"
      template "app/models/%plugin_path%/cloud_manager/refresher.rb"
      template "app/models/%plugin_path%/cloud_manager/vm.rb"
      template "app/models/%plugin_path%/inventory/collector/cloud_manager.rb"
      template "app/models/%plugin_path%/inventory/parser/cloud_manager.rb"
      template "app/models/%plugin_path%/inventory/persister/definitions/cloud_collections.rb"
      template "app/models/%plugin_path%/inventory/persister/cloud_manager.rb"
      template "app/models/%plugin_path%/inventory/persister.rb"
      template "app/models/%plugin_path%/cloud_manager.rb"

      # miq codename ivanchuk requires updates for miq_worker_types.rb. in miq codename Jansa we dont need it.
      worker_file = Rails.root.join('lib/workers/miq_worker_types.rb')
      if File.exist?(worker_file)
        inject_into_file worker_file, <<~RB.indent(2), :after => "MIQ_WORKER_TYPES = {\n"
          "#{class_name}::CloudManager::EventCatcher"                        => %i(manageiq_default),
          "#{class_name}::CloudManager::MetricsCollectorWorker"              => %i(manageiq_default),
          "#{class_name}::CloudManager::RefreshWorker"                       => %i(manageiq_default),
        RB
      end

    end

  end
end
