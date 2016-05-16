#!/usr/bin/env ruby

require 'facter'

fact_name = 'application_version'

if Facter.value(:kernel) == 'windows'

  filepath = 'C:\Program Files\Oracle\VirtualBox Guest Additions\VBoxControl.exe'
  file_version = nil 
  if File.exists?(filepath)

    exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
    script = <<-EOF
      $filepath = '#{filepath}'
      $info = get-item -path $filepath
      $raw_info  = $info.Versioninfo.ProductVersion
      $fact =  $raw_info  -replace '(\\d+\\.\\d+\\.\\d+)\\s+\\(Build\\s+(.+)\\)$' , '$1-$2'
      write-output $fact 
    EOF
        # Convert to a single-line snippet
        script.gsub!(/\n/, ';')
        if output = Facter::Util::Resolution.exec("#{exe} #{script}")
          file_version = output.split("\n").last
        end  
    Facter.add(fact_name) do
      setcode { file_version } 
    end
  end
end
