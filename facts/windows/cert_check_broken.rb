# checks for the ssl cert using Powershell (broken)

fact_name = 'cert_check'
cert_path = 'LocalMachine\TrustedPublisher'
cert_thumbprint = 'A88FD9BDAA06BC0F3C491BA51E231BE35F8D1AD5'

if Facter.value(:kernel) == 'windows'
  exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
  if File.exists?(exe)
    exe = "\"#{exe}\"" if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do
      	status = nil
       	script = <<-'EOF'
          $cert_thumbprint = 'A88FD9BDAA06BC0F3C491BA51E231BE35F8D1AD5'
          $cert_path= 'LocalMachine\TrustedPublisher'
          pushd cert:
          cd '\'
          cd $cert_path
          $items = get-childitem -path '.' | where-object { $_.thumbprint -eq $cert_thumbprint }
          foreach ($item in $items){
            if ( $item.thumbprint -eq $cert_thumbprint ) {
               write-output $item.thumbprint
               write-output 'true'
            }
          }
        EOF
        # this example demonstrates that injecting an intuitive from Powershell programmer's perspective code snippet
        # intended to print a true / false result dependent on the presence of a cert with spefic thumbprint under a specic path
        # does not work well in facter, for demostrative purposes the snippet is injected literally with interpolation turned off
        # the script does not generate the intended fact. When run standalone, the script works fine.

        # Convert to a single-line snippet
        script.gsub!(/\n/, ';')
        if output = Facter::Util::Resolution.exec("#{exe} #{script}")
          # Skip possible debugging output
          puts "Debug: " + output
          status = output.split("\n").last
          status
      	end
      end
    end
  end
end