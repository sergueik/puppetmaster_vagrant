require 'spec_helper'

RSpec.describe Specinfra::Command::Windows::Base::RegistryKey do
  let(:key_path) { "HKLM\\Software\\Microsoft\\Windows" }
  describe 'methods' do
    subject  { should respond_to(:check_exists).with(1).arguments  }
    subject  { should respond_to(:check_has_property).with(2).arguments  }
    subject  { should respond_to(:check_has_value).with(2).arguments  }
    subject  { should respond_to(:check_has_propertyvaluecontaining).with(2).arguments  }
  end

  def stub_exec (command)
    expect(described_class).to receive(:create_command).with(command)
  end

  describe 'has_property?' do
    it {
      stub_exec "(Get-Item 'Registry::#{key_path}') -ne $null"
      described_class.check_exists(key_path)
    }
  end

  [:type_dword, :type_dword_converted].each do |reg_type|
    it "has_property_value #{reg_type}" do
      prop = {:name => 'CurrentVersion', :type => reg_type}
      stub_exec "(Get-Item 'Registry::#{key_path}').GetValueKind('CurrentVersion') -eq 'DWord'"
      described_class.check_has_property key_path, prop
    end
  end
  [:type_dword, :type_dword_converted].each do |reg_type|
    describe 'check_has_value' do
      it {
        value = reg_type == :type_dword_converted ? "23" : "17"
        prop = {:name => 'CurrentVersion', :type => reg_type, :value => value}
        cmd = "(Compare-Object (Get-Item 'Registry::#{key_path}').GetValue('CurrentVersion') 23) -eq $null"
        stub_exec cmd
        described_class.check_has_value key_path, prop
      }
    end
    describe 'check_has_propertyvaluecontaining' do
      let(:value)  { '42' } 
      it {
        prop = {:name => 'CurrentVersion', :value => value}
        cmd = "(Get-Item 'Registry::#{key_path}').GetValue('CurrentVersion') -match '#{value}'"
        stub_exec cmd
        described_class.check_has_propertyvaluecontaining key_path, prop
      }
    end
  end

end
