# based on: https://github.com/liamjbennett/puppet-win_facts/blob/master/lib/facter/windows_sid.rb
# there is a number of other keys to convert to facts
# the other option is to exec the native tool 'gpresult.exe /scope computer /v'
# http://www.windowsnetworking.com/articles-tutorials/netgeneral/Under-Hood-Group-Policy.html

Facter.add('windows_sid') do
  confine :kernel => 'windows'
  setcode do  
    begin
      if Facter.value(:kernel) == 'windows' 
      # a (faster) alternative is
      # if RUBY_PLATFORM.downcase.include?('mswin') or RUBY_PLATFORM.downcase.include?('mingw32')
        require 'win32/registry'
        
        access = Win32::Registry::KEY_READ | 0x100 # wow6432
        key = 'Software\Microsoft\Windows\CurrentVersion\Group Policy'
      
        Win32::Registry::HKEY_LOCAL_MACHINE.open(key, access) do |reg|
          reg.keys.select {|key| key.start_with?('S-1-5-21')}.first.gsub(/(-500|-1001)$/,'')
        end
      end
    rescue
      'unknown'
    end
  end
end

