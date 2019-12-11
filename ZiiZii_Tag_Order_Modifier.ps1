$shutdown = $false

while($shutdown -ne $true) {

$confNumber = Read-Host -Prompt 'Enter last 4 of the confirmation number'

Copy-Item -Path ('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Archive\ZT_' + $confNumber + '.txt') -Destination ('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Inbox\ZO_' + $confNumber + '.txt')

Invoke-Item '\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Inbox'

$shutdownPrompt = Read-Host -prompt 'Run Again? [Y/N]'
    if($shutdownPrompt -eq 'N' -or $shutdownPrompt -eq 'n') {
        $shutdown = $true
    }
    elseif($shutdownPrompt -eq 'Y' -or $shutdownPrompt -eq 'y') {
        $shutdown = $false
    }
    else {
        $shutdownPrompt
    }
}