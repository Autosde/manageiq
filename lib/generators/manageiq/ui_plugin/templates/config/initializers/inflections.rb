ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym("<%= ui_plugin_name.split('_').map(&:capitalize).join(' ') %>")
end
