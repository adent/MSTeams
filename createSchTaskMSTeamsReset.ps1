$script = @"
#Stop Teams process 
Get-Process -ProcessName Teams -ErrorAction SilentlyContinue | Stop-Process -Force 

Start-Sleep -Seconds 3

#Clear Team Cache
try{Get-ChildItem "$env:APPDATA\Microsoft\Teams\*" -directory | Where name -in ('cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | ForEach{Remove-Item $_.FullName -Recurse -Force}
}catch{
echo $_ 
}

# start Teams
Start-Process -File $env:LOCALAPPDATA\Microsoft\Teams\Update.exe -ArgumentList '--processStart "Teams.exe"'
"@
New-Item -ItemType Directory -Force -Path C:\ITSupport\bin | Out-Null
Out-File -FilePath "C:\ITSupport\bin\FixTeams.ps1" -InputObject $script
# Create Scheduled Task to Reset Teams. 
$ac = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "C:\ITSupport\bin\FixTeams.ps1"
$tr = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$ta = Register-ScheduledTask -TaskName "ResetTeams" -Trigger $tr -Action $ac 