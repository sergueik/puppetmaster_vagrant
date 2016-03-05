require_relative '../windows_spec_helper'

context 'Junctions ans Reparse Points' do

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

# what is the API to read directory junction target ? 
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

# What is the API to read symlink target ? 
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


$is_junction = Test-DirectoryJunction -test_path 'c:\\temp\\test'
write-output ('is junction: {0}' -f $is_junction )

$junction_target = Get-DirectoryJunctionTarget  -test_path 'c:\\temp\\test'
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

context 'Junctions and Symlinks - Basic' do
  link_name = 'splunkuniversalforwarder'
  describe command(' cmd /c dir /L "c:\Program Files"') do
    its(:stdout) { should contain "<SYMLINKD>     #{link_name}" }
  end
end
