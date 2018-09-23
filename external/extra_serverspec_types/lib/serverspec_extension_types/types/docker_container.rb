require 'serverspec'

module Serverspec::Type
  # This class  monkey patches serverspec's docker container type with some more method to be used in matchers
  class DockerContainer
    def include_regex?
      inspection.find { |str| str =~ regex }
    end

    def has_image?(image)
      self.image == image
    end

    def has_image_sha?(image)
      self.image_sha == image
    end

    def image
      inspection['Config']['Image'].split('@')[0]
    end

    def image_sha
      inspection['Config']['Image'].split('@')[1]
    end

    def has_environment_variable?(regex, value = nil)
      if value
        environment_variable(regex) == value
      else
        environment_variable(regex)
      end

    end

    def environment_variable(regex)
      environment_variables.find { |str| str =~ /^#{regex}=/ }.split('=')[1]
    end

    def environment_variables
      inspection['Config']['Env']
    end

    def has_user?(user)
      self.user == user
    end

    def user
      inspection['Config']['User']
    end

    def has_hostname?(hostname)
      self.hostname == hostname
    end

    def hostname
      inspection['Config']['Hostname']
    end

    def has_domainname?(domain)
      self.domain_name == domain
    end

    def domain_name
      inspection['Config']['Domainname']
    end

    def has_restart_limit?(limit)
      restart_limit == limit
    end

    def restart_limit
      inspection['HostConfig']['RestartPolicy']['MaximumRetryCount']
    end

    def has_restart_policy?(policy)
      restart_policy == policy
    end

    def restart_policy
      inspection['HostConfig']['RestartPolicy']['Name']
    end
    def has_host?(host)
      hosts.include? host
    end
    def hosts
      inspection['HostConfig']['ExtraHosts'].map {|itm| itm.split(':')[1] + ' ' + itm.split(':')[0]}
    end

    def privileged?
      inspection['HostConfig']['Privileged']
    end

    # TODO: matcher for this
    def publishes_all_ports?
      inspection['HostConfig']['PublishAllPorts']
    end


    def map_port?(host, container, protocol = 'tcp')
      inspection['NetworkSettings']['Ports']["#{container}/#{protocol}"][0]['HostPort'] == host
    end

    def port_map
      inspection['HostConfig']['PortBindings']
    end

    def has_mount?(source, target, type)
      mounts.find { |mount| mount['Source'] == source && mount['Destination'] == target && mount['Type'] == type }
    end

    def mounts
      inspection['Mounts']
    end

    # TODO: matcher for volumes

    private

    def get_inspection
      @containers ||=  @name.include?('=') ? @runner.run_command("docker ps -qa -f #{@name}").stdout : @name
      @get_inspection ||= @runner.run_command("docker inspect #{@containers}")
    end
  end
end
