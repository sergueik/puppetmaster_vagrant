require_relative '../windows_spec_helper'

context 'Junctions ans Reparse Points' do

  # Powershell 5.0 supports creating and detecting of symbolic link directly
  context 'Powershell 5.0' do
    symlink_path = 'c:\Temp\B'
    target_path = 'c:\temp\a'
    before(:each) do

      Specinfra::Runner::run_command( <<-END_COMMAND
        $target_path = '#{target_path}'
        $symlink_path = '#{symlink_path}'
        $target_parent_path = $target_path -replace '\\\\[^\\\\]+$',''
        $target_directory_name = $target_path -replace '^.+\\\\',''
        pushd $target_parent_path
        New-Item -ItemType Directory -Name $target_directory_name -ErrorAction SilentlyContinue
        popd
        if (Test-Path -Path $symlink_path) {
          # NOTE: Powershell will warn you 
          # remove-item : C:\temp\#{symlink_path} is an NTFS junction point. 
          # Use the Force parameter to delete or modify this object.
          Remove-Item -Path $symlink_path -Force
        }
        $symlink_parent_path = $symlink_path -replace '\\\\[^\\\\]+$',''
        $symlink_directory_name = $symlink_path -replace '^.+\\\\',''
        pushd $target_parent_path
        # NOTE: Powershell will warn you 
        # New-Item : Administrator privilege required for this operation.
        New-Item -ItemType SymbolicLink -Name "${symlink_directory_name}" -Target $target_path
        popd
      END_COMMAND
      )
    end

    describe command( <<-EOF
    $symlink_path = '#{symlink_path}'
    get-item -path $symlink_path | select-object -property 'LinkType' | format-list
    get-item -path $symlink_path | select-object -expandproperty 'Target'
  EOF
  ) do
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /LinkType\s+:\s+SymbolicLink/  }
      its(:stdout) { should contain Regexp.new(target_path) }
    end
  end
end

