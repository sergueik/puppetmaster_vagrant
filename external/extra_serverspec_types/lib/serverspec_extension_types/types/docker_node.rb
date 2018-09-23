module Serverspec::Type
  class DockerNode < DockerBase

    def active?
      availability == 'active'
    end

    def availability
      inspection['Spec']['Availability']
    end

    def role
      inspection['Spec']['Role']
    end

    def manager?
      role == 'manager'
    end

    def worker?
      role == 'worker'
    end

    def labels
      inspection['Spec']['Labels']
    end

    def has_engine_version?(version)
      engine_version == version
    end

    def engine_version
      inspection['Description']['Engine']['EngineVersion']
    end
    private

    def get_inspection
      @get_inspection ||= @runner.run_command("docker service inspect #{@name}")
    end
  end
end
