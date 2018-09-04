if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'Disk Drives' do
  # based on http://www.cyberforum.ru/powershell/thread2317585.html
  describe command (<<-EOF
    Get-WmiObject Win32_DiskDrive | foreach-object {
      $disk = $_
      $partitions = 'ASSOCIATORS OF ' +
                    "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                    'WHERE AssocClass = Win32_DiskDriveToDiskPartition'
      Get-WmiObject -query $partitions | foreach-object  {
        $partition = $_
        $drives = 'ASSOCIATORS OF ' +
                  "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
                  'WHERE AssocClass = Win32_LogicalDiskToPartition'
        Get-WmiObject -query $drives | foreach-object  {
          new-object -type PSCustomObject -property @{
            Disk        = $disk.DeviceID
            DiskNumber  = $disk.Index
            Partition   = $partition.Name
            DriveLetter = $_.DeviceID
            VolumeName  = $_.VolumeName
          }
        }
      }
    } | format-list
  EOF
  ) do
  {
    'Partition'   => 'Disk #0, Partition #\d+',
    'DiskNumber'  => '0',
    'DriveLetter' => '[D|C|E]:',
  }.each do |key,val|
    its(:stdout) { should match /#{key}\s+:\s+#{val}/ }
  end
    its(:exit_status) {should eq 0 }
  end
end
