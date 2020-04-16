$datafile= 'data.csv'
$table_name = 'event'
$db_name = 'event'
# origin:
$command = @"
.open ${db_name}
drop table ${table_name};
create table ${table_name} (
        date text,
        day int,
        month int, 
        year int,
        user text,
        pc text,
        printer text,
        page int,
        copies int,
        totalpage int
);
 
.mode csv
.separator , 
.import ${datafile} ${table_name}
 
select user from ${table_name};
 
.quit 
"@
# origin: https://www.cyberforum.ru/powershell/thread2619980.html
# According tp Microsoft
# powershell.exe is not cmd.exe. One thing it lacks is an input redirector
# powershell has more powerful facilities
 
$script = "${env:TEMP}\command.sql"
out-File -FilePath $script -Encoding ascii -InputObject $command;
write-output 'Version 1'
get-content $script | sqlite3.exe
write-output 'Version 2'
cmd %%- /c "sqlite3.exe -batch < ${script} ${db_name} && exit"