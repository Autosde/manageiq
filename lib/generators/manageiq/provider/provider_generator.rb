require_relative "../plugin/plugin_generator"

module ManageIQ
  class ProviderGenerator < PluginGenerator

    @@abstract_classes_array << name

    source_root File.expand_path('templates', __dir__)

    class_option :vcr, :type => :boolean, :default => false,
                 :desc => "Enable VCR cassettes (Default: --no-vcr)"

    class_option :dummy, :type => :boolean, :default => false,
                 :desc => "Generate dummy implementations (Default: --no-dummy)"

    class_option :dev, :type => :boolean, :default => false,
                 :desc => "Add override_gem to overrides.rb to bypass git in the main Gem file (Default: --no-dev)"

    class_option :dec_path, :type => :string, :default => 'plugins/manageiq-decorators',
                 :desc => "Path to manageiq-decorators"

    class_option :ui, :type => :string,
                 :desc => "Add ui for the new provider. Full path to the vendor icon image can be provider as additional argument."

    def create_provider_files
      empty_directory "spec/models/#{plugin_path}"

      gsub_file "lib/tasks_private/spec.rake", /'app:test:spec_deps'/ do |match|
        "[#{match}, 'app:test:providers_common']"
      end

      create_dummy if options[:dummy]
      create_vcr   if options[:vcr]
      create_dev   if options[:dev]
      create_ui    if options[:ui]
    end

    private

    # abstract method for create_dummy. Overwrite it in each provider class
    def create_dummy
      raise NotImplementedError.new("You must implement create_dummy.")
    end

    def create_vcr
      inject_into_file '.yamllint', "  /spec/vcr_cassettes/**\n", :after => "  /spec/manageiq/**\n"

      append_file 'spec/spec_helper.rb', <<~VCR
  
          VCR.configure do |config|
            config.ignore_hosts 'codeclimate.com' if ENV['CI']
            config.cassette_library_dir = File.join(#{class_name}::Engine.root, 'spec/vcr_cassettes')
          end
      VCR
    end

    def create_dev
      override_file = Rails.root.join('bundler.d','overrides.rb')
      if (File.exist?(override_file))
        inject_into_file override_file,
                         "override_gem '%s', path: '%s'\n" % [plugin_name, self.destination_root]
      else
        create_file override_file,
                    "override_gem '%s', path: '%s'\n" % [plugin_name, self.destination_root]
      end
    end

    def create_ui
      update_ui_angular
      update_ui_haml
      update_ui_js
      copy_icon
    end

    def update_ui_angular
      if self.class.name == 'ManageIQ::PhInfraProviderGenerator'
        provider_name = "ManageIQ::Providers::#{file_name.capitalize}::PhysicalInfraManager"
      elsif self.class.name == 'ManageIQ::CloudProviderGenerator'
        provider_name = "ManageIQ::Providers::#{file_name.capitalize}::CloudManager"
      else
        puts "Warning: Failed to modify required fields to support default UI form submission. Please check the provider type."
        return
      end

      inject_path = Rails.root.join('plugins/manageiq-ui-classic/app/controllers/mixins/ems_common/angular.rb')

      inject_into_file inject_path, <<~RB.indent(8), :after => "case ems.to_s\n"
        when '#{provider_name}'
          [user, password, params[:default_hostname]]
      RB

      inject_into_file inject_path, <<~RB.indent(8), :after => "kubevirt_endpoint = {}\n"
        \nif ems.kind_of?(#{provider_name})
          default_endpoint = {:role => :default, :hostname => hostname}
        end
      RB
    end

    def copy_icon
      dst_path = "#{options[:dec_path]}/app/assets/images/svg/vendor-#{file_name}.svg"
      src_file = options[:ui]

      if options[:ui] == "ui"
        source_paths << File.expand_path('resources', __dir__)
        src_file = File.expand_path("resources/vendor-miq.svg", __dir__)
      end

      if src_file.end_with?(".svg") 

        copy_file(src_file, Rails.root.join(dst_path))
      else
        puts "Warning: Icon file should be in SVG format"
      end
    end

    def update_ui_haml
      inject_into_file Rails.root.join('plugins/manageiq-ui-classic/app/views/layouts/angular/_multi_auth_credentials.html.haml'), <<~RB.indent(16), :after => "\"#\{ng_model\}.emstype == 'gce'                    || \" + |\n"
         "#\{ng_model\}.emstype == '#{file_name}'                    || " + |
      RB
    end

    def update_ui_js
      inject_into_file Rails.root.join('plugins/manageiq-ui-classic/app/assets/javascripts/controllers/ems_common/ems_common_form_controller.js'), <<~RB.indent(8), :after => "$scope.emsCommonModel.emstype === 'ec2' ||\n"
         $scope.emsCommonModel.emstype === '#{file_name}' ||
      RB
    end

  end
end