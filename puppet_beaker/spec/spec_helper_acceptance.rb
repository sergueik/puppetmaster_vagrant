require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

# Utilitário para instalar agente do Puppet
run_puppet_install_helper

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|

  c.before :suite do
    hosts.each do |host|
      # Instala dependências utilizando Puppet
      on host, puppet('module', 'install', 'puppetlabs-apache')

      # Copia módulo sendo testado para servidor provisionado
      copy_module_to(host, source: PROJECT_ROOT, module_name: 'example')
    end
  end

end
