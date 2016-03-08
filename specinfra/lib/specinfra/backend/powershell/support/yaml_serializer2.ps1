# origin: https://github.com/scottmuc/PowerYaml
# https://github.com/aaubry/YamlDotNet

function Add-CastingFunctions ($value) {
  if ($PSVersionTable.PSVersion -ge '3.0') { return $value }
  return Add-CastingFunctionsForPosh2 ($value)
}

function Add-CastingFunctionsForPosh2 ($value) {
  return Add-Member -InputObject $value -Name ToInt -MemberType ScriptMethod -PassThru -Value `
     { [int]$this } |
  Add-Member -Name ToLong -MemberType ScriptMethod -PassThru -Value `
     { [long]$this } |
  Add-Member -Name ToDouble -MemberType ScriptMethod -PassThru -Value `
     { [double]$this } |
  Add-Member -Name ToDecimal -MemberType ScriptMethod -PassThru -Value `
     { [decimal]$this } |
  Add-Member -Name ToByte -MemberType ScriptMethod -PassThru -Value `
     { [byte]$this } |
  Add-Member -Name ToBoolean -MemberType ScriptMethod -PassThru -Value `
     { [System.Boolean]::Parse($this) }
}

function get-YamlStreamFromString([string]$data) {
  $sr = New-Object System.IO.StringReader ($data)
  $o = New-Object YamlDotNet.RepresentationModel.YamlStream
  $o.Load([System.IO.TextReader]$sr)
  return $o
}

function Get-YamlStreamFromFile ([string]$file) {
  $t = [System.IO.File]::OpenText($file)
  $o = New-Object YamlDotNet.RepresentationModel.YamlStream
  $o.Load([System.IO.TextReader]$t)
  $t.Close()
  return $o
}

function Explode-Node ($node) {
  $node_name = $node.GetType().Name
  if ($node_name -eq 'YamlScalarNode') {
    return Convert-YamlScalarNodeToValue $node
  } elseif ($node_name -eq 'YamlMappingNode') {
    return Convert-YamlMappingNodeToHash $node
  } elseif ($node_name -eq 'YamlSequenceNode') {
    return Convert-YamlSequenceNodeToList $node
  }
}

function Convert-YamlScalarNodeToValue ($node) {
  return Add-CastingFunctions ($node.Value)
}

function Convert-YamlMappingNodeToHash ($node) {
  $hash = @{}
  $c = $node.Children
  foreach ($key in $c.Keys) {
    $hash[$key.Value] = Explode-Node $c[$key]
  }
  return $hash
}

function Convert-YamlSequenceNodeToList ($node) {
  $list = @()
  foreach ($n in $node.Children) {
    $list += Explode-Node $n
  }
  return $list
}

# NOTE: does not work well with secondary Powershell shell instances
function Get-ScriptDirectory

{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}


function OpenLog {
  param([string]$runlog)

  $shared_assemblies_path = 'C:\developer\sergueik\csharp\SharedAssemblies'
  # http://stackoverflow.com/questions/14894864/how-to-download-a-nuget-package-without-nuget-exe-or-visual-studio-extension
  # http://www.nuget.org/api/v2/package/<assembly>/<version>

  $shared_assemblies = @(
    'YamlDotNet.dll',# '3.7.0'
    'nunit.core.dll' # '3.0.0-beta-4'
    'nunit.framework.dll' # TODO - check if still needed
  )

  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    Unblock-File -Path $_
    # Write-Host -foregroundcolor 'Cyan' $_
    Add-Type -Path $_
  }
  popd
  $data = (Get-Content -Path $runlog) -join "`n"
  $yaml = get-YamlStreamFromString $data
  $log = Explode-Node $yaml.RootNode
  return $log

}

<#
.SYNOPSIS
	Confirms the presence of a specific message from resource specific type, title in the Puppet last run log
.DESCRIPTION
	Inspects the Puppet last run log's declaration of resource of the caller provided type, title and finds if there is event with specific message text
	
.EXAMPLE
	exec "FindResourceEventMessage '#{puppet_run_log}' -name '#{resource_name}' -type '#{resource_type}' -text '#{message_text}'"
	
.LINK
	
.NOTES
	VERSION HISTORY
	2016/01/24 Initial Version
#>

function FindResourceEventMessage {
  param(
    [string]$log,
    [string]$name,
    [string]$type,
    [bool]$changed = $true,
    [string]$text = ''
  )
  $found = $false
  $runlog = OpenLog ($log)
  $data = $runlog['resource_statuses']
  $data.Keys | Where-Object { $_ -match '^(?:\w+)\[(?:\w+)\]$' } |
  ForEach-Object {
    $resource = $_

    if ($resource -match '^(\w+)\[(\w+)\]$') {
      $resource_type = $matches[1]
      $resource_title = $matches[2]
      if ($resource_type -eq $type -and $resource_title -eq $name) {
        if ($message -eq '' -or ($data[$resource]['changed'] -eq 'true')) {
          Write-Host -ForegroundColor 'yellow' ('Resource:{0}[{1}] Event: {2}' -f $type,$name,$text)
          @( 'resource_type',
            'title') | ForEach-Object {
            $key = $_
            Write-Host -ForegroundColor 'green' ('{0}: {1}' -f $key,$data[$resource][$key])
          }
          Write-Host -ForegroundColor 'blue' ('message: {0}' -f $data[$resource]['events']['message'])
          $found = $true
        }
      }
    }
  }
  return $found

}


<#
.SYNOPSIS
	Confirms the presence of a resource with specific type, title, and changed state in the Puppet last run log
.DESCRIPTION
	Evaluates the Puppet last run log looking for declaration of resource with given type, title, and changed state
	
.EXAMPLE
	exec "FindResource -log '#{puppet_run_log}' -name '#{resource_name}' -type '#{resource_type}'"
	
.LINK
	
.NOTES
	VERSION HISTORY
	2016/01/24 Initial Version
#>

function FindResource {
  param(
    [string]$log,
    [string]$name,
    [string]$type,
    [bool]$changed = $true
  )
  $found = $false
  $runlog = OpenLog ($log)
  $data = $runlog['resource_statuses']
  $data.Keys | Where-Object { $_ -match '^(?:\w+)\[(?:\w+)\]$' } |
  ForEach-Object {
    $resource = $_
    if ($resource -match '^(\w+)\[(\w+)\]$') {
      $resource_type = $matches[1]
      $resource_title = $matches[2]
      if ($resource_type -eq $type -and $resource_title -eq $name) {
        if ((-not $changed) -or ($data[$resource]['changed'] -eq 'true')) {
          Write-Host -ForegroundColor 'yellow' ('Resource:{0}[{1}]:{2}' -f $type,$name,$changed)
          @( 'resource_type',
            'title') | ForEach-Object {
            $key = $_
            Write-Host -ForegroundColor 'green' ('{0}: {1}' -f $key,$data[$resource][$key])
          }
          @(
            'skipped',
            'failed',
            'changed'
          ) | ForEach-Object {
            $key = $_
            Write-Host -ForegroundColor 'green' ('{0}: {1}' -f $key,($data[$resource][$key] -eq 'true'))
            $found = $true
          }
        }
      }
    }
  }
  return $found
}

<#
.SYNOPSIS
	Evaluates presence of a given text in the Puppet last run log messages
.DESCRIPTION
	Evaluates the Puppet last run log detecing presence of specific message text fragment
	
.EXAMPLE
	exec "FindMessage -text '#{text}'" [-source '#{source}']
	
.LINK
	
.NOTES
	VERSION HISTORY
	2016/01/24 Initial Version
#>


function FindMessage {
  param(
    [string]$log,
    [string]$text,
	[string]$source 
  )
  $runlog = OpenLog ($log)
  $found = $false
  $runlog['logs'] |
  ForEach-Object {
    $entry = $_
    if ($entry['message'] -match $text) {
	  if (($source -eq '') -or ($entry['source'] -match "\b${source}\b")) {
        Write-Host -ForegroundColor 'yellow' ('Logs: "{0}"' -f $text)
        Write-Host -ForegroundColor 'green' $entry['message']
	    Write-Host -ForegroundColor 'green' $entry['source']
        $found = $true
	  }
    }
  }
  return $found
}
