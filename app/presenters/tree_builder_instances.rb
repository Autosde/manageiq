class TreeBuilderInstances < TreeBuilder
  has_kids_for AvailabilityZone, [:x_get_tree_az_kids]
  has_kids_for ExtManagementSystem, [:x_get_tree_ems_kids]

  def tree_init_options(_tree_name)
    {
      :leaf => 'VmCloud'
    }
  end

  def set_locals_for_render
    locals = super
    locals.merge!(
      :tree_id   => "instances_treebox",
      :tree_name => "instances_tree",
      :id_prefix => "instances_",
      :autoload  => true
    )
  end

  def root_options
    [_("Instances by Provider"), _("All Instances by Provider that I can see")]
  end

  def x_get_tree_roots(count_only, _options)
    objects = Rbac.filtered(EmsCloud.order("lower(name)"), :match_via_descendants => VmCloud)
    objects += [
      {:id => "arch", :text => _("<Archived>"), :image => "currentstate-archived", :tip => _("Archived Instances")},
      {:id => "orph", :text => _("<Orphaned>"), :image => "currentstate-orphaned", :tip => _("Orphaned Instances")}
    ]
    count_only_or_objects(count_only, objects)
  end

  def x_get_tree_ems_kids(object, count_only)
    objects = Rbac.filtered(object.availability_zones.order("name")) +
              Rbac.filtered(object.vms.where(:availability_zone_id => nil).order("name"))
    count_only ? objects.length : objects
  end

  # Get AvailabilityZone children count/array
  def x_get_tree_az_kids(object, count_only)
    objects = Rbac.filtered(object.vms.order("name"))
    objects = objects.reject { |obj| obj.archived? || obj.orphaned? } ## TODO: turn into a scope instead of ruby
    count_only ? objects.length : objects
  end

  include TreeBuilderArchived
end
