require 'ffi'

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

filename = 'c:\Program Files\Windows NT\Accessories\wordpad.exe'
filename = 'c:\Windows\system32\notepad.exe'
size_in_bytes = Test.version_resource_size_bytes(filename, '')
result = ' ' * size_in_bytes
status = Test.version(filename, 0, size_in_bytes, result)


# puts size_in_bytes
# puts result
rstring = result.unpack('v*').map{ |s| s.chr if s < 256 } *'' 
rstring = rstring.gsub(/\000/, ' ')
puts rstring
      version_match = /FileVersion\s+\b([0-9.]+)\b/.match(rstring)
puts version_match
      version = version_match[1].to_s
puts version

#  the following is  incomplete  and does not work 
result_value_size = FFI::MemoryPointer.new(:long, size_in_bytes)
version_information = '\VarFileInfo\Translation'.encode('UTF-16LE')
result_value = ' ' * size_in_bytes
status = Test.verqueryvalue(result, version_information, '', result_value_size)
# https://docs.omniref.com/ruby/gems/ffi-extra/0.0.1/symbols/FFI::Pointer/read_array_of	
puts result_value_size.read_long()

result_value = ' ' * result_value_size.read_long()
status = Test.verqueryvalue(result, version_information, result_value, result_value_size)

puts result_value