require_relative '../windows_spec_helper'

context 'Junctions ans Reparse Points' do

  context 'Parsing cmd output' do

    symlink_path = 'c:\Temp\B'
    target_path = 'c:\temp\a'
    describe command( <<-EOF

  # Confirm that a given path is a Windows NT symlink
  function Test-SymLink([string]$test_path) {
    $file_object = Get-Item $test_path -Force -ErrorAction Continue
    return [bool]($file_object.Attributes -band [IO.FileAttributes]::Archive ) `
                 -and  `
           [bool]($file_object.Attributes -band [IO.FileAttributes]::ReparsePoint )
  }

  # Confirm that a given path is a Windows NT directory junction
  function Test-DirectoryJunction([string]$test_path) {
    $file_object = Get-Item $test_path -Force -ErrorAction Continue
    return [bool]($file_object.Attributes -band [IO.FileAttributes]::Directory ) `
                 -and  `
           [bool]($file_object.Attributes -band [IO.FileAttributes]::ReparsePoint)
  }

  # TODO: API to read directory junction target
  function Get-DirectoryJunctionTarget([string]$test_path) {

    $command = ('cmd /c dir /L /-C "{0}"' -f
                [System.IO.Directory]::GetParent($test_path ))
    $capturing_match_expression = ( '(?:<JUNCTION>|<SYMLINKD>)\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f
                                    [System.IO.Path]::GetFileName($test_path ))
    $result = $null
    (invoke-expression -command $command ) |
              where-object { $_ -match $capturing_match_expression } |
                select-object -first 1 |
                  forEach-object {
                    $result =  $matches['TARGET']
                  }
    return $result

  }

  # TODO:  API to read symlink target
  function Get-SymlinkTarget([string]$test_path) {

    $command = ('cmd /c dir /L /-C "{0}"' -f [System.IO.Directory]::GetParent($test_path ))
    $capturing_match_expression = ( '<SYMLINK>\\s+{0}\\s+\\[(?<TARGET>.+)\\]' -f
                                    [System.IO.Path]::GetFileName($test_path ))
    $result = $null
    (invoke-expression -command $command ) |
      where { $_ -match $capturing_match_expression } |
        select-object -first 1 |
          forEach-object {
            $result =  $matches['TARGET']
          }
    return $result

  }
  $symlink_path = '#{symlink_path}'
  $is_junction = Test-DirectoryJunction -test_path $symlink_path
  write-output ('is junction: {0}' -f $is_junction )

  $junction_target = Get-DirectoryJunctionTarget  -test_path $symlink_path
  write-output ('junction target: {0}' -f $junction_target )

  $is_symlink = Test-Symlink -test_path 'c:\\temp\\specinfra'
  write-output ('is symlink: {0}' -f $is_symlink )

  $symlink_target = Get-SymlinkTarget  -test_path 'c:\\temp\\specinfra'
  write-output ('symlink target: {0}' -f $symlink_target )

  EOF
  ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /is symlink: True/  }
      its(:stdout) { should match /symlink target: specinfra-2.43.5.gem/i   }
      its(:stdout) { should match /is junction: True/  }
      its(:stdout) { should match /junction target: c:\\windows\\softwareDistribution/i   }
    end
  end
end
context 'Junctions and Symlinks - Basic' do
  link_name = 'splunkuniversalforwarder'
  describe command(' cmd /c dir /L "c:\Program Files"') do
    its(:stdout) { should contain "<SYMLINKD>     #{link_name}" }
  end
end

# origin: https://raw.githubusercontent.com/guitarrapc/PowerShellUtil/master/SymbolicLink/Get-SynbolicLink.ps1
context 'Junctions and Symlinks - Powershell calling C# SymbolicLink' do
  link_name = 'splunkuniversalforwarder'
  describe command(<<-EOF
[System.IO.File]::GetAttributes([System.IO.FileInfo]($file_reparsepoint_link))
# Archive, ReparsePoint, NotContentIndexed
 [System.IO.File]::GetAttributes([System.IO.DirectoryInfo]($regular_directory))
# Directory, NotContentIndexed
 [System.IO.File]::GetAttributes([System.IO.DirectoryInfo]($directory_reparsepoint_link))
# Directory, ReparsePoint, NotContentIndexed
# https://msdn.microsoft.com/en-us/library/system.io.fileattributes%28v=vs.110%29.aspx
$expected = @([System.IO.FileAttributes]::Archive, [System.IO.FileAttributes]::ReparsePoint,, [System.IO.FileAttributes]::NotContentIndexed ) -join ', '
#Archive, ReparsePoint, NotContentIndexed
  EOF
  ) do
    its(:exit_status) {should eq 0 }
  end
end

