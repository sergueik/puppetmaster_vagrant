if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'Default Console Font Size' do
  context 'TrueType' do
    # based on http://forum.oszone.net/thread-301356.html
    # see also pinvoke (dllimport)-heavy way
    # https://4sysops.com/archives/change-powershell-console-font-size-with-cmdlet/    
    # https://gallery.technet.microsoft.com/scriptcenter/cb72e4e6-4a68-4a2e-89b7-cc43a860349e 
    size = 19
    # NOTE: odd sizes e.g. 19 can only be set through registry manipulation or kernel32.dll method
    describe command(<<-EOF
      pushd HKCU:/Console/%SystemRoot%_System32_cmd.exe
      $raw_data = get-itemproperty -path '.' -name 'FontSize' | select-object -expandproperty 'FontSize'
      write-output ('Raw data: {0}({1})' -f $raw_data,  [convert]::toString($raw_data, 16 ) )
      # e.g.
      # 1179648 (120000)
      # 1245184(130000)
      write-output ('Console font size: {0}' -f ([Convert]::toInt32( 0 + ( [convert]::toString($raw_data, 16 )).Substring(0,2) , 16) ))
      popd
    EOF
    ) do
      its(:stdout) { should_not match /Console font size: #{size}/ }
    end
  end
end