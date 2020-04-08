require_relative "../plugin/plugin_generator"

module ManageIQ
  class UiPluginGenerator < PluginGenerator
    source_root File.expand_path('templates', __dir__)

    class_option :vcr, :type => :boolean, :default => false,
                 :desc => "Enable VCR cassettes (Default: --no-vcr)"

    class_option :dummy, :type => :boolean, :default => false,
                 :desc => "Generate dummy implementations (Default: --no-dummy)"

    class_option :dev, :type => :boolean, :default => false,
                 :desc => "Add override_gem to overrides.rb to bypass git in the main Gem file (Default: --no-dev)"

    def create_ui_plugin_files
      empty_directory "spec/models/#{plugin_path}"

      create_dummy if options[:dummy]
      create_vcr   if options[:vcr]
      create_dev   if options[:dev]

      modify_engine_file
    end

    private

    alias ui_plugin_name file_name

    def create_dummy
      template "app/assets/stylesheets/%plugin_path%/application.css"
      template "app/assets/stylesheets/%plugin_path%/base.scss"
      template "app/controllers/%ui_plugin_name%_controller.rb"
      template "app/views/%ui_plugin_name%/index.html.haml"
      template "config/initializers/inflections.rb"
      template "config/routes.rb"
      template "db/fixtures/miq_product_features.yml"
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

    def modify_engine_file
      inject_into_file "lib/%plugin_path%/engine.rb", <<~RB.indent(6), :after => "config.autoload_paths << root.join('lib').to_s"
        \n\ninitializer 'plugin' do
          Menu::CustomLoader.register(
            Menu::Section.new(:#{ui_plugin_name}, N_("#{ui_plugin_name.split('_').map(&:capitalize).join(' ')}"), 'fa fa-plus fa-2x', [
              Menu::Item.new('#{ui_plugin_name}_demo', N_('demo'), '#{ui_plugin_name}_demo', {:feature => '#{ui_plugin_name}_demo', :any => true}, '/#{ui_plugin_name}/index'),
            ], nil, nil, nil, nil, :compute)
          )
        end
      RB
    end

  end
end
