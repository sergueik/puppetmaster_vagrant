# On Windows platform facter role is often reduced to dispatching the fact generation to WMI
# based on: https://github.com/mmornati/mcollective-windows/blob/master/facts/dns.rb
{
  'dnsdomain' => {
    :query => 'Select DNSDomain From Win32_NetworkAdapterConfiguration Where IPEnabled = True',
    :field => 'DNSDomain'
  },
  'dnshostname' => {
    :query => 'Select DNSHostName From Win32_NetworkAdapterConfiguration Where IPEnabled = True',
    :field => 'DNSHostName'
  },
  'dnsservers' => {
    :query => 'Select DNSServerSearchOrder From Win32_NetworkAdapterConfiguration Where IPEnabled = True',
    :field => 'DNSServerSearchOrder'
  },
}.each do |fact_name, wmi_data|

  Facter.add(fact_name) do
    confine :kernel => 'windows'
    setcode do
        require 'facter/util/wmi'
        result = nil
        query = wmi_data[:query]
        field = wmi_data[:field]
        Facter::Util::WMI.execquery(query).each do |o|
          result = o.send(field.to_sym)
          break
        end
        result
    end
  end
end

# will never be empty
# fact_name = 'dnshostname'
