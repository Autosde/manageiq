class <%= ui_plugin_name.split('_').map(&:capitalize).join('') %>Controller < ApplicationController
  include Mixins::MenuUpdateMixin

  # type the controller code here. below is an example for connection to a view html.haml file named index

  def index
    @layout = '<%= ui_plugin_name %>'
    @page_title = _('<%= ui_plugin_name.split('_').map(&:capitalize).join(' ') %>')
  end

end
