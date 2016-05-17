#!/usr/bin/env ruby

require 'facter'

require 'facter'

fact_name = 'vboxcontrol_version'

if Facter.value(:kernel) == 'windows'
  module Test
    extend FFI::Library
    ffi_lib 'version.dll'
    ffi_convention :stdcal
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647005%28v=vs.85%29.aspx
    attach_function :version_resource_size_bytes, :GetFileVersionInfoSizeA,  [ :pointer, :pointer ], :int
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647003%28v=vs.85%29.aspx
    attach_function :version, :GetFileVersionInfoA,  [ :pointer, :int, :int, :buffer_out ], :int
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647464%28v=vs.85%29.aspx
    version_information = '\VarFileInfo\Translation'.encode('UTF-16LE')
    attach_function :verqueryvalue, :VerQueryValueA,  [ :buffer_in, :buffer_in, :buffer_out, :pointer ], :int
  end
  def versioninfo_ffi_version(filepath)
  
    # contains two alternative code snippets, one unfinished, equally cryptic
    
    file_version = nil
    size_in_bytes = Test.version_resource_size_bytes(filepath, nil)
    if size_in_bytes != 0
      result = ' ' * size_in_bytes
      status = Test.version(filepath, 0, size_in_bytes, result)
      rstring = result.unpack('v*').map{ |s| s.chr if s < 256 } * '' 
      rstring = rstring.gsub(/\000/, ' ')
      version_match = /FileVersion\s+\b([0-9.]+)\b/.match(rstring)
      version_value = version_match[1].to_s
      file_version = version_value

      #  the following is  incomplete  and does not work 
      result_value_size = FFI::MemoryPointer.new(:long, size_in_bytes)
      version_information = '\VarFileInfo\Translation'.encode('UTF-16LE')
      result_value = ' ' * size_in_bytes
      status = Test.verqueryvalue(result, version_information, '', result_value_size)
      # https://docs.omniref.com/ruby/gems/ffi-extra/0.0.1/symbols/FFI::Pointer/read_array_of	

      result_value = ' ' * result_value_size.read_long()
      status = Test.verqueryvalue(result, version_information, result_value, result_value_size)
      # file_version = result_value
    end
    file_version    
  end
  
  def versioninfo_version(filepath)
    file_version = nil
    require 'Win32API'
    
    if File.exists?(filepath)

      # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647005%28v=vs.85%29.aspx
      size_in_bytes = Win32API.new('version.dll', 'GetFileVersionInfoSize',  ['P', 'P'], 'L').call(filepath, nil)
      if size_in_bytes > 0
        result = "\0" * size_in_bytes
        Win32API.new('version.dll', 'GetFileVersionInfo', ['P', 'L', 'L', 'P'], 'L').call(filepath, 0, size_in_bytes, result)
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
      # versioninfo_version(filepath)
      # versioninfo_ffi_version(filepath) # vboxcontrol_version = '4.3.8.92456'
      powershell_get_version(filepath)  # vboxcontrol_version = '4.3.8.r92456'
    end 
  end
end
