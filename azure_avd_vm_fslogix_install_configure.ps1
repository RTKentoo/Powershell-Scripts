$hostpoolName = 'gfsi-w-avd-hp'
$resourceGroup = 'gfsi-w-avd-rg'
$vmName = [System.Net.Dns]::GetHostByName($env:computerName).hostname
$assignedUser = (get-azwvdsessionhost -resourcegroupname $resourceGroup -hostpoolname $hostpoolName).assigneduser



Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
 choco install fslogix -y;
 reg add HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles /v Enabled /t REG_DWORD /d 1; reg add HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles /v VHDLocations /t REG_MULTI_SZ /d \\gfsiwavduserprofilesa.file.core.windows.net\profiles;
 net use f: \\gfsiwavduserprofilesa.file.core.windows.net\profiles /user:Azure\gfsiwavduserprofilesa mubZzXU+mNyvwi99EbmNIsoM8UBfrP5yf7T/AH5dk23LzYW4Fpp7bfsDIGShJoz55Jm3QnKlthUg9GWeiOI8vA==;
 icacls f: /grant "${assignedUser}:(M)"; icacls f: /grant '"Creator Owner":(OI)(CI)(IO)(M)'; icacls f: /remove "Authenticated Users"; icacls f: /remove "Builtin\\Users"
