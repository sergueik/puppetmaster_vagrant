# determine system root
$systemroot = get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name systemroot |select-object -expandproperty systemroot
# excluding first level directories
# note: it appears miltiple exclude does not work with -recurse 
# see also:
# https://stackoverflow.com/questions/15294836/how-can-i-exclude-multiple-folders-using-get-childitem-exclude
$exclude1 = "*WinSxS*","*AppCompat*","*Assembly*","*Boot*","*cursors*","*Microsoft.NET","*Servicing*","*PLa*","*System32*", "*SysWOW64*","*Temp*"
get-ChildItem -path $systemroot -Exclude $exclude1| where-object {$_.psiscontainer} | select-object -expandproperty FullName |foreach-object { get-ChildItem -path $_ -Recurse -file | where-object {-not $_.psiscontainer} } | select-object -expandproperty FullName

# Workaround: exclude some folders under "System32" with a big number of files  or denied access
$exclude2 = "*Catroot*","*wdi*","*driverstore*","MsDtc","Configuration","Config","Logfiles","networklist","inetsrv"

get-ChildItem -path "${systemroot}\System32" -Exclude $exclude2| where-object {$_.psiscontainer} | select-object -expandproperty FullName |foreach-object { get-ChildItem -path $_ -Recurse -file | where-object {-not $_.psiscontainer} } | select-object -expandproperty FullName
