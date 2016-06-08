pushd C:\tools
$PWD =  pwd | select-object -expandproperty PATH
$env:PATH="${env:PATH};${PWD}"
# write-output $env:PATH
$data = invoke-expression -command ". .\uru.ps1 ls"
write-output ("data = '{0}'" -f $data )
# $data -match '^\s+\b(\w+)\b.*$'
$tag = ($data -replace '^\s+\b(\w+)\b.*$', '$1')
write-output ("tag = '{0}'" -f $tag )
$env:URU_INVOKER = 'powershell'
uru_rt.exe $tag
uru_rt.exe ruby C:\tools\serverspec\ruby\lib\ruby\gems\2.1.0\gems\rake-11.1.2\bin\rake spec

popd 
