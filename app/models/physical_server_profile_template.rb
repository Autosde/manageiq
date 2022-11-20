class PhysicalServerProfileTemplate < ApplicationRecord
  acts_as_miq_taggable

  include NewWithTypeStiMixin
  include TenantIdentityMixin
  include SupportsFeatureMixin
  include EventMixin
  include ProviderObjectMixin
  include EmsRefreshMixin

  include_concern 'Operations'

  belongs_to :ext_management_system, :foreign_key => :ems_id, :inverse_of => :physical_server_profile_templates,
    :class_name => "ManageIQ::Providers::PhysicalInfraManager"

  delegate :queue_name_for_ems_operations, :to => :ext_management_system, :allow_nil => true

  def my_zone
    ems = ext_management_system
    ems ? ems.my_zone : MiqServer.my_zone
  end

  def self.check
    bulk=ManageIQ::Providers::CiscoIntersight::PhysicalInfraManager.first.connect(:service=>'BulkApi')
    cloner=ManageIQ::Providers::CiscoIntersight::PhysicalInfraManager.first.connect(:service=>'BulkMoCloner')
    cloner = IntersightClient::BulkMoCloner.new(
      {
        :sources => [{"Moid" => '6346f11a77696e2d300b6049', "ObjectType" => 'server.ProfileTemplate'}],
        :targets => [{"Name" => 'new-new', "ObjectType": 'server.Profile'}]
      }
    )
    result = bulk.create_bulk_mo_cloner(cloner)
    new_profile_moid = result.responses[0].body.moid

    puts new_profile_moid



  end
end
