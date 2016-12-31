require_relative '../windows_spec_helper'

context 'Desktop Window Size' do
  context 'Windows Forms' do
    describe command(<<-EOF
      [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
      $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
      $primaryScreen | select-object -Expandproperty 'Bounds' |
      select-object -property Width,Height |
      format-list
    EOF
    ) do
      {
        'Width' => 1920,
        'Height' => 1080,
      }.each do |key,val|
        its (:stdout) { should match Regexp.new(key + '\s*:\s+' + val.to_s) }
      end
    end
    describe command(<<-EOF
      [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

      $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
      $primaryScreen | select-object -Expandproperty 'WorkingArea' |
      select-object -property Width,Height |
      format-list
    EOF
    ) do
      {
        'Width' => 1920,
        'Height' => 1032,
      }.each do |key,val|
        its (:stdout) { should match Regexp.new(key + '\s*:\s+' + val.to_s) }
      end
    end
  end
  context 'WMI information' do
    # NOTE: some, e.g. VirtualBox Graphics Adapter may not even filll the data
    describe command(<<-EOF
      get-wmiobject -class 'Win32_VideoController' |
      where-object { $_.Availability  -eq '3' } |
      select-object -first 1 |
      select-object -property CurrentHorizontalResolution, CurrentVerticalResolution,VideoModeDescription,Caption,PNPDeviceID |
      format-list
    EOF
    ) do
      {
        'CurrentHorizontalResolution' => 1920,
        'CurrentVerticalResolution'   => 1080,
      }.each do |key,val|
        its (:stdout) { should match Regexp.new(key + '\s*:\s+' + val.to_s) }
      end
    end
  end
end
