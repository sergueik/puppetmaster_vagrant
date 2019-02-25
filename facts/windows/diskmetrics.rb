fact_name = 'diskmetrics'

# see also https://stackoverflow.com/questions/2903169/calculate-free-space-of-c-drive-using-vbscript
Facter.add(fact_name) do
  setcode do
    confine :operatingsystem => :windows
    result = {}
    require 'win32ole'

    wmi_namespace = 'winmgmts://./root/CIMV2'
    # wmi_query = "select * from Win32_LogicalDisk"
    # wmi_query = "select * from Win32_LogicalDisk where DeviceID=\"C:\""
    wmi_query = "select * from Win32_LogicalDisk where DriveType=3"
    $stderr.puts ('WMI query: ' + wmi_query)
    wmi_fields = ['FreeSpace', 'DeviceID','DriveType','Availability','Size','Status']
    wmi = WIN32OLE.connect(wmi_namespace)
    query = wmi.ExecQuery(wmi_query)

    query.each do |o|
      field_result = nil
      wmi_fields.each do |wmi_field|
        field_result = o.send(wmi_field.to_sym)
        result[wmi_field] = field_result
      end
      break
    end
    pp(result,out = $stderr,nil)
    result.to_s
  end
end
