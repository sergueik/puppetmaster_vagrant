require 'serverspec'
require 'serverspec/type/base'
require 'serverspec/type/docker_base'

module Serverspec::Type
  class DockerService < DockerBase
    def exist?
      get_inspection.success?
    end

    def has_restart_policy?(policy)
      restart_policy == policy
    end

    def has_restart_limit?(limit)
      restart_limit == limit
    end

    def restart_policy
      inspection['Spec']['TaskTemplate']['RestartPolicy']['Condition']
    end

    def restart_limit
      inspection['Spec']['TaskTemplate']['RestartPolicy']['MaxAttempts']
    end

    def has_image?(image)
      self.image == image
    end

    def has_image_sha?(image)
      self.image == image
    end

    def image
      inspection['Spec']['TaskTemplate']['ContainerSpec']['Image'].split('@')[0]
    end

    def image_sha
      inspection['Spec']['TaskTemplate']['ContainerSpec']['Image'].split('@')[1]
    end

    def has_user?(user)
      self.user == user
    end

    def user
      inspection['Spec']['TaskTemplate']['ContainerSpec']['User']
    end

    def has_mount?(source, target, type)
      mounts.find do |mount|
        mount['Source'] == source && mount['Target'] == target && mount['Type'] == type
      end
    end

    def mounts
      inspection['Spec']['TaskTemplate']['ContainerSpec']['Mounts']
    end

    def has_host?(host)
      hosts.include? host
    end

    def hosts
      inspection['Spec']['TaskTemplate']['ContainerSpec']['Hosts']
    end

    def has_placement_constraint?(constraint)
      placement_constraints.include? constraint
    end

    def placement_constraints
      inspection['Spec']['TaskTemplate']['Placement']['Constraints']
    end

    def replicated?
      inspection['Spec']['Mode']['Replicated']
    end

    def replicas
      ['Spec']['Mode']['Replicated']['Replicas']
    end
    def global?
      inspection['Spec']['Mode']['Global']
    end

    def replicas
      inspection['Spec']['Mode']['Replicated']['Replicas']
    end

    def networks
      inspection['Spec']['TaskTemplate']['Networks']
    end

    def has_network?(name)
      networks.find { |network| network['Aliases'].include? name }
    end

    def port_map
      inspection['Spec']['EndpointSpec']['Ports']
    end

    def map_port?(published, target, protocol = 'tcp',mode = 'ingress')
      port_map.find do |port|
        port['PublishedPort'] == published.to_i &&
          port['TargetPort'] == target.to_i && port['PublishMode'] == mode &&
          port['Protocol'] == protocol
      end
    end


    private

    def get_inspection
      @get_inspection ||= @runner.run_command("docker service inspect #{@name}")
    end
  end
end

include Serverspec::Type
