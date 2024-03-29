$hostpoolName = ''
$resourceGroup = ''
$vmName = [System.Net.Dns]::GetHostByName($env:computerName).hostname
$assignedUser = (get-azwvdsessionhost -resourcegroupname $resourceGroup -hostpoolname $hostpoolName).assigneduser



Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
 choco install fslogix -y;
 reg add HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles /v Enabled /t REG_DWORD /d 1; reg add HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles /v VHDLocations /t REG_MULTI_SZ /d \\storageaccount.file.core.windows.net\container;
 net use f: \\storageaccount.file.core.windows.net\profiles /user:Azure\container key;
 icacls f: /grant "${assignedUser}:(M)"; icacls f: /grant '"Creator Owner":(OI)(CI)(IO)(M)'; icacls f: /remove "Authenticated Users"; icacls f: /remove "Builtin\\Users"
