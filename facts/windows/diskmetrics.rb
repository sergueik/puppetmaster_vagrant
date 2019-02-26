fact_name = 'diskmetrics'
@debug = false
# NOTE: with older facter: undefined method `setcode' for #<Facter::Core::Aggregate:0x4529178> (NoMethodError)
# Facter.add(fact_name, :type => :aggregate) do
Facter.add(fact_name) do
  setcode do
    confine :operatingsystem => :windows
    result = []
    require 'win32ole'

    wmi_namespace = 'winmgmts://./root/CIMV2'
    # wmi_query = "select * from Win32_LogicalDisk"
    # wmi_query = "select * from Win32_LogicalDisk where DeviceID=\"C:\""
    wmi_query = "select * from Win32_LogicalDisk where DriveType=3"
    if @debug
      $stderr.puts ('WMI query: ' + wmi_query)
    end
    wmi_fields = %w|DeviceID Size FreeSpace|
    wmi = WIN32OLE.connect(wmi_namespace)
    query = wmi.ExecQuery(wmi_query)
    query.each do |o|
      result_row = {}
      result_column = nil
      wmi_fields.each do |wmi_field|
        if @debug
          $stderr.puts ('processing ' + wmi_field )
        end
        result_column = o.send(wmi_field.to_sym)
        if @debug
          $stderr.puts ('got ' + result_column )
        end
        result_row[wmi_field] = result_column
      end
      if @debug
        pp(result_row,out = $stderr,nil)
      end
      result.push result_row
      # collect all disks
      # NOTE: will possibly have redundant data in the result ?
      # pp(result,out = $stderr,nil)
      # break
    end
    # see also https://stackoverflow.com/questions/2903169/calculate-free-space-of-c-drive-using-vbscript
    # http://rubyonwindows.blogspot.com/2007/07/using-ruby-wmi-to-get-win32-process.html
    # NOTE: need to build the structured fact as in
    # https://puppet.com/docs/facter/3.9/fact_overview.html#writing-structured-facts
    # diskmetrics = '[{"DeviceID" => "C:", "Size" => "25570570240", "FreeSpace" => "1190244352"}, {"DeviceID" => "E:", "Size" => "2238705664", "FreeSpace" => "2198364160"}]'
    if @debug
      pp(result, out = $stderr,nil)
    end
    if @debug
      $stderr.puts result.to_json
    end
    # result.to_json
    result
  end
end
