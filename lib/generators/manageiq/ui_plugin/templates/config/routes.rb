Rails.application.routes.draw do
  match '/<%= ui_plugin_name %>' => '<%= ui_plugin_name %>#index', :via => [:get]
  match '<%= ui_plugin_name %>/*page' => '<%= ui_plugin_name %>#index', :via => [:get]

end
