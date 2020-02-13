#
# Description: <Method description here>
#
module Automation
  module Provider
    class Volumes

      def initialize(handle = $evm, name='my-svc')
        @handle = handle
        @name = name
      end

      def main
        do_stuff
      end

      def do_stuff
        vm = @handle.root['vm'].name
        pool = @handle.root['dialog_pools']
        vol_name = @handle.root['dialog_volume_name']
        vol_size = @handle.root['dialog_volume_size']
        svc =  $evm.vmdb(:ext_management_system).where(:name=>@name).first
        puts "IN VOLUMES"
        p svc
        puts "calling create and attach volume"
        cat = svc.object_send('create_and_attach_volume', vol_name, vol_size, vm, pool)
        puts cat
      end
    end
  end
end

#puts $evm.root.attributes

Automation::Provider::Volumes.new.main

