require 'spec_helper'
require_relative '../type/command'
require 'yaml'
require 'json'
require 'csv'

context 'Confirm able to load XML' do
  jobs_dir = '/opt/jenkins/jobs'
  config_dir = '/vagrant'
  [
    'good.xml',
    'bad.xml'
  ].each do |config|
    xml = "#{config_dir}/#{config}"
    describe command( "cat #{xml}") do
      its(:stdout_as_xml) { should respond_to :version }
    end
  end
end
