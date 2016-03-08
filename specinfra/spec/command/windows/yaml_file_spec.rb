require 'spec_helper'

RSpec.describe Specinfra::Command::Windows::Base::YamlFile  do 
  let(:puppet_log) { 'last_report.yaml' }
  let(:resource_name) {'dummy'} 
  let(:resource_type) {'Exec'} 
  let(:message) {'executed successfully'}
  let(:source) {'executor'}

  describe 'methods' do
    subject  { should respond_to(:check_has_message).with(2).arguments  }
  end
  def stub_exec (command)
    expect(described_class).to receive(:exec).with(command)
  end

    describe 'check_exec_disabled' do
      xit {
        cmd = "..."
        # exec not called directly
        stub_exec cmd
        described_class.check_has_message puppet_log, message, source
      }
    end

  describe 'check_has_resource' do
    it do
      expect(described_class).to receive(:generate_command).with( puppet_log, resource_name, resource_type,'FindResource')
      described_class.check_has_resource puppet_log, resource_name, resource_type
    end
  end

  describe 'check_has_message' do
    it do
      expect(described_class).to receive(:generate_command).with( puppet_log, message,'FindMessage')
      described_class.check_has_message puppet_log, message
    end
  end

  describe 'check_has_resource_message' do
    it do
      expect(described_class).to receive(:generate_command).with( puppet_log, resource_name, resource_type, message,'FindResourceEventMessage')
      described_class.check_has_resource_message puppet_log, resource_name, resource_type, message
    end
  end
end
