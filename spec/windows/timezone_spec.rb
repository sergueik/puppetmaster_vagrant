require_relative '../windows_spec_helper'
context 'Time Zone' do
  # [System.TimeZoneInfo]::Local
  # Id                         : Eastern Standard Time
  # DisplayName                : (UTC-05:00) Eastern Time (US & Canada)
  # StandardName               : Eastern Standard Time
  # DaylightName               : Eastern Daylight Time
  # BaseUtcOffset              : -05:00:00
  # SupportsDaylightSavingTime : True
  # custom format https://msdn.microsoft.com/en-us/library/8kb3ddd4%28v=vs.90%29.aspx

  describe command(<<-EOF) do
  #
  write-output ([Regex]::Replace([System.TimeZoneInfo]::Local.StandardName, '([A-Z])\\w+\\s*', '$1'))
  write-output ("{0:h:mm:ss tt zzz K}" -f (get-date)) # zero-padded offset from UTC

Add-Type -TypeDefinition @"
using System;
using System.Globalization;
public class Example {
   public static string Test()  {
      CultureInfo ci = CultureInfo.InvariantCulture;
      DateTime today = DateTime.Today;
      return (today.ToString("hh:mm:ss tt zzz K", ci));
      }
}
"@ -ReferencedAssemblies 'mscorlib.dll' 

write-output ([Example]::Test())

  EOF
   its (:stdout) {should contain 'PST'}
   its (:stdout) {should contain '-07:00'}
  end
end


