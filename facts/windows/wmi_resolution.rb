# origin: https://github.com/adenning/winfacts/blob/master/lib/facter/monitor_resolution.rb

fact_name = 'videomode_description'

Facter.add(fact_name) do
  setcode do
    confine :operatingsystem => :windows
    result = ''
    require 'win32ole'
    wmi_namespace = 'winmgmts://./root/CIMV2'
    wmi_query = 'select * from Win32_VideoController'
    wmi_field = 'Caption'
    # 'VideoModeDescription', 'CurrentVerticalResolution', 'CurrentHorizontalResolution'
    # also defined but not always pupulated by the driver vendor
    wmi = WIN32OLE.connect(wmi_namespace)
    query = wmi.ExecQuery(wmi_query)
    query.each do |o|
      result = o.send(wmi_field.to_sym)
      break
    end
    puts "#{wmi_field} = '#{result}'"
    result
  end
end