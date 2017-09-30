require_relative '../windows_spec_helper'

context 'UAC' do
  # based on: https://github.com/SHIFT-ware/shift_ware/blob/master/Serverspec/spec/2-0001_Base/ID/2-0001-013_Uac_spec.rb
  # NOTE: values change with Windows releases
  registry_data = {
    'high' => {
      'EnableLUA' => '1',
      'PromptOnSecureDesktop' =>'1',
      'ConsentPromptBehaviorAdmin' => '2',
    },
    'medium' => {
      'EnableLUA' => '1',
      'PromptOnSecureDesktop' =>'1',
      'ConsentPromptBehaviorAdmin' => '5',
    },
    'low' => {
      'EnableLUA' => '1',
      'PromptOnSecureDesktop' =>'0',
      'ConsentPromptBehaviorAdmin' => '5',
    },
    'disabled' => {
      'EnableLUA' => '1',
      'PromptOnSecureDesktop' =>'0',
      'ConsentPromptBehaviorAdmin' => '0',
    },
    'lua_disabled' =>
    {
      'EnableLUA' => '0',
      'PromptOnSecureDesktop' =>'0',
      'ConsentPromptBehaviorAdmin' => '0',
    },
  }

  level = 'low'

  describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System') do
    context "#{level} UAC" do
    expected_data = registry_data[level]
    expected_data.each do |value, data|
      it { should have_property_value(value, :type_dword, data) }
    end
  end
  end
end
