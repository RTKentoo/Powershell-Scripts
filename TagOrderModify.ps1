function TagOrderModify {

    param ()

    $shutdown = $false
    
    [System.Console]::Clear()

    while($shutdown -ne $true) {
        $fileExists = $false
        $confNumber = $null

        ### Check for Tag Order, then Scannable if no Tag Order is found and set path ###
        while($fileExists -ne $true) {
            $confNumber = Read-Host -Prompt 'Enter last 4 of the confirmation number'

            try {
                if ( [System.IO.File]::Exists('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Archive\ZT_' + $confNumber + '.txt') ) {
                    $path = ('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Archive\ZT_' + $confNumber + '.txt')
                    $fileExists = $true
                } elseif ( [System.IO.File]::Exists('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Archive\ZS_' + $confNumber + '.txt') ){
                    $path = ('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Archive\ZS_' + $confNumber + '.txt')
                    $fileExists = $true
                } else {
                    Write-Host 'Not able to find a Tag Order or Scannable with that confirmation number.'
                    sleep 4
                    [System.Console]::Clear()
                    $fileExists = $false
                }
            } catch {
                [System.Console]::Clear()
            }
        }

        ### Confirm move/modify with file and account details ###
        $accountNumber = (Get-Content -Path $path | Select-Object -First 1).substring(2,6)
        $fileName = (Get-ChildItem ($path)).BaseName
        $currentUser = $env:UserName
        $currentDate = (Get-Date -format "MM/dd/yyy HH:mm")
        
        $requestingUser = Read-Host -Prompt ('Who is making this request?')
        $confContinue = Read-Host -Prompt ('Would you like to modify the file ' + $fileName + ' from account ' + $accountNumber + ' to an order? [Y/N]')

        if ($confContinue -eq 'Y' -or $confContinue -eq 'y') {
            try {
                Copy-Item -Path ($path) -Destination ('\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Inbox\ZO_' + $confNumber + '.txt')
                
                Get-ChildItem '\\harborfoods\files\Automation\ZiiZii\PRODUCTION\Inbox'

                Add-Content '\\harborfoods\files\Automation\ZiiZii\Documentation\Log_TagOrderModification.txt' ($currentDate + ' || ' + $fileName + ' requested to be modified to order for account:' + $accountNumber + ' from ' + $requestingUser + '  ||  Request fulfilled by ' + $currentUser)
                sleep 4
            } catch {
                Write-Host 'File not found in Archives.'
            } 
        } else {
            Write-Host 'Cancelling operation.'
            sleep 2
        }

        [System.Console]::Clear()
        $shutdownPrompt = Read-Host -prompt 'Run Again? [Y/N]'

        if($shutdownPrompt -eq 'N' -or $shutdownPrompt -eq 'n') {
            $shutdown = $true
        } else {
            [System.Console]::Clear()
        }
    }

    return 'Error'
}