class StorageVolume < ApplicationRecord
  #include_concern 'Operations'

  include NewWithTypeStiMixin
  include ProviderObjectMixin
  include AsyncDeleteMixin
  include AvailabilityMixin
  include SupportsFeatureMixin
  include CustomActionsMixin

  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ExtManagementSystem"
  belongs_to :storage_resource, :foreign_key => :storage_resource_id, :class_name => "StorageResource"
  belongs_to :storage_service, :foreign_key => :storage_service_id, :class_name => "StorageService"

  #has_many   :attachments, :class_name => 'Disk', :as => :backing

  acts_as_miq_taggable

  def self.available
    #left_outer_joins(:attachments).where("disks.backing_id" => nil)
  end

  def self.class_by_ems(ext_management_system)
    # TODO(lsmola) taken from OrchesTration stacks, correct approach should be to have a factory on ExtManagementSystem
    # side, that would return correct class for each provider
    ext_management_system && ext_management_system.class::StorageVolume
  end

  # Create a storage volume as a queued task and return the task id. The queue
  # name and the queue zone are derived from the provided EMS instance. The EMS
  # instance and a userid are mandatory. Any +options+ are forwarded as
  # arguments to the +create_volume+ method.
  #
  def self.create_volume_queue(userid, ext_management_system, options = {})
    task_opts = {
        :action => "creating Cloud Volume for user #{userid}",
        :userid => userid
    }

    queue_opts = {
        :class_name  => 'StorageVolume',
        :method_name => 'create_volume',
        :role        => 'ems_operations',
        :queue_name  => ext_management_system.queue_name_for_ems_operations,
        :zone        => ext_management_system.my_zone,
        :args        => [ext_management_system.id, options]
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def self.create_volume(storage_resource_id, size, name, options = {})
    # @type [StorageResource]
    storage_resource = StorageResource.find(storage_resource_id)
    raise ArgumentError, _("Storage resource could not be found") if storage_resource.nil?

    # @type [ExtManagementSystem]
    ext_management_system = storage_resource.ext_management_system
    raise ArgumentError, _("ext_management_system cannot be found") if ext_management_system.nil?

    # @type [class<StorageVolume>]
    klass = ext_management_system.storage_volumes.klass
    klass.raw_create_volume(ext_management_system, storage_resource, size, name, options)
  end

  def self.validate_create_volume(ext_management_system)
    klass = class_by_ems(ext_management_system)
    return klass.validate_create_volume(ext_management_system) if ext_management_system &&
        klass.respond_to?(:validate_create_volume)
    validate_unsupported("Create Volume Operation")
  end

  def self.raw_create_volume(ext_management_system, storage_resource, size, name, options = {})
    raise NotImplementedError, _("raw_create_volume must be implemented in a subclass")
  end

  # Update a cloud volume as a queued task and return the task id. The queue
  # name and the queue zone are derived from the EMS, and a userid is mandatory.
  #
  def update_volume_queue(userid, options = {})
    task_opts = {
        :action => "updating Cloud Volume for user #{userid}",
        :userid => userid
    }

    queue_opts = {
        :class_name  => self.class.name,
        :method_name => 'update_volume',
        :instance_id => id,
        :role        => 'ems_operations',
        :queue_name  => ext_management_system.queue_name_for_ems_operations,
        :zone        => ext_management_system.my_zone,
        :args        => [options]
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def update_volume(options = {})
    raw_update_volume(options)
  end

  def validate_update_volume
    validate_unsupported("Update Volume Operation")
  end

  def raw_update_volume(_options = {})
    raise NotImplementedError, _("raw_update_volume must be implemented in a subclass")
  end

  # Delete a cloud volume as a queued task and return the task id. The queue
  # name and the queue zone are derived from the EMS, and a userid is mandatory.
  #
  def delete_volume_queue(userid)
    task_opts = {
        :action => "deleting Cloud Volume for user #{userid}",
        :userid => userid
    }

    queue_opts = {
        :class_name  => self.class.name,
        :method_name => 'delete_volume',
        :instance_id => id,
        :role        => 'ems_operations',
        :queue_name  => ext_management_system.queue_name_for_ems_operations,
        :zone        => ext_management_system.my_zone,
        :args        => []
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def delete_volume
    raw_delete_volume
  end

  def validate_delete_volume
    validate_unsupported("Delete Volume Operation")
  end

  def raw_delete_volume
    raise NotImplementedError, _("raw_delete_volume must be implemented in a subclass")
  end

  def available_vms
    raise NotImplementedError, _("available_vms must be implemented in a subclass")
  end
end
