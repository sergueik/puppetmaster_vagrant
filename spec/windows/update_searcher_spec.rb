require_relative '../windows_spec_helper'
require 'win32ole'
require 'pp'

context 'Update Searcher' do

  # This example connects to 'Microsoft.Update.Session' COM object to perform 
  # pending update search for current Windows version on the instance
  # expects to successgully pick first few update titles from the returned result
  # NOTE: will work on Windows 2012 or newer, see exception notes below
  # NOTE: example script is very time consuming, blocking

  # based on https://raw.githubusercontent.com/singlestone/Windows_Scripts_Examples/master/Powershell_Scripts/Last%20installed%20update.ps1
  # and
  # https://github.com/OSDeploy/Microsoft-Windows-Updates/blob/master/WUA_UpdatesInternet.vbs

  describe Object, 'test of the update searvcher com object' do

    # IUpdateSession
    # https://msdn.microsoft.com/en-us/library/windows/desktop/aa386854(v=vs.85).aspx
    $obj_session = WIN32OLE.new('Microsoft.Update.Session')
    # IUpdateSearcher
    # https://msdn.microsoft.com/en-us/library/windows/desktop/aa386515(v=vs.85).aspx
    $obj_searcher = $obj_session.CreateUpdateSearcher()
    startIndex = 1
    count = 1
    # show the latest installed update
    $obj_history = $obj_searcher.QueryHistory(startIndex, count)
    $obj_history.each do |entry|
      puts entry.Title
      puts entry.Date
    end
    # search for updates pending install
    begin
      # NOTE: sensitive to quotes
      search_result = $obj_searcher.Search("IsInstalled=0 AND IsHidden=0 and Type='Software'")
    rescue => e
      $stderr.puts e.to_s
      # OLE error code:8024000E in <Unknown>
      # in `method_missing': (in OLE method `Search': ) (WIN32OLERuntimeError)
    end
    # NOTE: can not access as a Ruby collection
    if !search_result.nil?
      begin
        # pp search_result
        # pp search_result.Updates
        # pp search_result.Updates.Count
        search_result.Updates.take(4).each do |entry|
          $stderr.puts entry.Title
          # OLE error code:80240032 in <Unknown>
          #  <No Description>
        end
      rescue => e
        $stderr.puts e.to_s
        # unknown property or method: `take'
      end

      update_titles = []
      (0...search_result.Updates.Count-1).take(4).each do |item|
        obj_update = search_result.Updates.Item(item)
        update_titles << obj_update.Title
        $stderr.puts obj_update.Title
      end
    end

    # Output varies with OS and time the script is executed

    # on Windows 8.1
    # * Update for Windows 8.1 for x64-based Systems (KB4016754)
    # * Microsoft .NET Framework 4.7.1 for Windows 8.1 and Windows Server 2012 R2 for x64 (KB4033369)
    # * Windows Malicious Software Removal Tool x64 - April 2018 (KB890830)
    # * Update for Windows 8.1 for x64-based Systems (KB2976978)

    # on Windows 2012 Server    
    # Security Update for Microsoft .NET Framework 4.5.1 and 4.5.2 on Windows 8.1 and Windows Server 2012 R2 x64-based Systems (KB2978041)
    # Update for Microsoft .NET Framework 3.5 for x64-based Systems (KB3005628)
    # Security Update for Microsoft .NET Framework 4.5.1 and 4.5.2 on Windows 8.1 and Windows Server 2012 R2 x64-based Systems (KB2978126)
    # Security Update for Windows Server 2012 R2 (KB2982998)

    pp update_titles
    subject { update_titles }
    its(:length) {should be 4}
  end
end