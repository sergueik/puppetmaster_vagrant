#!/usr/bin/env ruby

require 'facter'

fact_name = 'application_version'

if Facter.value(:kernel) == 'windows'

  def versioninfo_version(filepath)
    file_version = nil
    require 'Win32API'
    
    if File.exists?(filepath)

      # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647005%28v=vs.85%29.aspx
      vsize = Win32API.new('version.dll', 'GetFileVersionInfoSize',  ['P', 'P'], 'L').call(filepath, nil)
      if (vsize > 0)
        result = "\0" * vsize
        Win32API.new('version.dll', 'GetFileVersionInfo', ['P', 'L', 'L', 'P'], 'L').call(filepath, 0, vsize, result)
        rstring = result.unpack('v*').map{|s| s.chr if s<256 } * ''
        r = /FileVersion..(.*?)\000/.match(rstring)      
        file_version = "#{r ? r[1] : '??' }"
      end
    end
  end
  def powershell_get_version(filepath)
    file_version = nil 
    if File.exists?(filepath)
      exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
      script = <<-EOF
        $filepath = '#{filepath}'
        $info = get-item -path $filepath
        $raw_info  = $info.Versioninfo.ProductVersion
        $fact =  $raw_info  -replace '(\\d+\\.\\d+\\.\\d+)\\s+\\(Build\\s+(.+)\\)\\s*$' , '$1-$2'
        write-output $fact 
      EOF
      # Convert to a single-line snippet
      script.gsub!(/\n/, ';')
      if output = Facter::Util::Resolution.exec("#{exe} #{script}")
        file_version = output.split("\n").last
      end
    end      
  end      
  Facter.add(fact_name) do
    setcode do
      filepath = 'C:\Program Files\Oracle\VirtualBox Guest Additions\VBoxControl.exe'
      versioninfo_version(filepath)
      powershell_get_version(filepath)
    end 
  end
end
