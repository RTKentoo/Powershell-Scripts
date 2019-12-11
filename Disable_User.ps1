function Disable-UserProcess
{
    Param
    (
        $LoginName
    )

<#
$userDept = ((((Get-ADUser -Identity $userGuid).DistinguishedName).split(","))[1]).trim('OU=')
#>
    Clear-Host
    $SDashCred = Get-Credential -UserName $LoginName -Message 'Disable User Process'
    $AzureLogin = $LoginName.trim("HARBORFOODS\\S-") + '@harborfoods.com'
    write-host $azurelogin

    Write-Host '[Q] to Exit'
    $userPrompt = Read-Host -Prompt 'Enter first and last name of user you would like to disable: '

    if ($userPrompt -eq 'Q' -or $userPrompt -eq 'q') {
        Return 'Error'
    } else {
        Try {
            $user = Get-ADUser -filter "Name -eq 'Rusty Shacklford'" -Properties * #MemberOf, Mail | Select-Object DistinguishedName, Objectguid, MemberOf, Mail
            if ($user -eq $null) {
                clear
                Write-Host 'User not found.'
                Throw
            }
        } Catch {
            Write-Error -Message 'No such user found.'
            Start-sleep -Seconds '1'
            Return 'Error'
        }
    }

    $isUserEmailForward = $false
    $user | Select-Object Name, SamAccountName, EmailAddress | Format-List

    #Controls the Do loop
    $SuccessfullyDisabledUser = $false
    Do {
        
        $DisableUserVerificationAnswer = Read-Host -prompt 'Are you sure that you would like to DISABLE this user?[Y/N]'

        if ($DisableUserVerificationAnswer -eq 'Y' -or $DisableUserVerificationAnswer -eq 'y') {

            ######################
            #   Email Forward    #
            ######################
 
            #Forward Email Prompt
            $emailPrompt = Read-Host -Prompt 'Will this user need their email forwarded for 30 days? [Y/N]'
            if ($emailPrompt -eq 'Y') {  
                $disabledContainer = 'OU=Support Desk,OU=Information Technology,OU=Users,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
                
                #Open Exchange Connection
                Import-Module '\\poshsrv.harborfoods.com\HostedScripts\users\Request Elevation\Modules\O365 Tools' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue           
                try {
                    Write-Host 'Creating Exchange Session...'
                    Connect-O365ExchSession -errorAction Stop -WarningAction SilentlyContinue  
                } catch {
                    Write-Host 'Unable to connect to Exchange Server. Terminating session'
                    Start-Sleep '3'
                    Remove-ExchangeOnlineSession
                    $_ | Out-File 'C:\ErrorLogs\ErrorLog.txt' -Append
                    return 'Error'
                }

                #Forward Email Error Check
                $retryLoop = 0
                $stopLoop = $false
                while ($stoploop -eq $false) {
                    $emailForwardRecipient = Read-Host -prompt ('Enter the first and last name of the email forwarding recipient.')
                    try {
                        $emailForwardUser = Get-Aduser -filter "name -eq '$emailForwardRecipient'" -Properties Mail -ErrorAction Stop
                        if ($emailForwardUser -eq $null) {
                            Throw
                        } else {
                            $stoploop = $true
                        }
                    } catch {
                        Write-Host 'User not found.'
                        start-sleep -Seconds '1'
                        $_ | Out-File ('\\ldc-posh-01\HostedScripts\Kent\Error Logs\ErrorLog.txt') -Append
                    } finally {
                        if($retryLoop -ge 2) {
                            $stopLoop = $true
                        } else {
                            $retryLoop++ 
                        }
                    }    
                } 

                try {
                    Set-Mailbox -Identity $user.mail -ForwardingSmtpAddress $emailForwardUser.mail
                    Write-Host ('Email for ' + $user.Name + ' is now forwarding to ' + $emailForwardUser.mail)
                    Remove-ExchangeOnlineSession
                } catch {
                    Write-Host ('Unable to forward ' + $user.mail + ' to ' + $emailForwardRecipient.mail)
                    Remove-ExchangeOnlineSession
                    Start-Sleep -s '1'
                    $_ | Out-File ('\\ldc-posh-01\HostedScripts\Kent\Error Logs\ErrorLog.txt') -Append
                }

                Move-ADObject $user.objectGUID -TargetPath $disabledContainer -Credential $SDashCred
                
            } else {
                $disabledContainer = 'OU=Kent Disabled,OU=Kent Testing,OU=Support Desk,OU=Information Technology,OU=Users,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
                Move-ADObject $user.objectGUID -TargetPath $disabledContainer -Credential $SDashCred
            }


            ######################
            #   Account Disable  #
            ######################

            #Create and set random password
            $asci = [char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126))
            $password = (1..$(Get-Random -Minimum 20 -Maximum 21) | ForEach-Object { $asci | get-random }) -join ""
            Set-ADAccountPassword -Identity $user.objectGUID -NewPassword ( $password | ConvertTo-SecureString -AsPlainText -Force) -Reset -Verbose -Credential $SDashCred

            #Disable Account
            Write-Host ('Disabling account belonging to {0}...' -f $user.name)
            Start-Sleep -s '2'
            #Set-ADUser -Identity $user.objectguid -Enabled:$false -Credential $SDashCred 
            Disable-ADAccount -Identity $user.objectguid -Credential $SDashCred -verbose

            #Add Limited Accounts Membership, Set Primary Membership to Limited
            $limitedAccts = Get-ADGroup "Limited Accounts" -Properties *
            $primaryLimitedAccts = Get-ADGroup 'Limited Accounts' -Properties @("primaryGroupToken")
            Write-Host ('Adding Limited Account membership. Setting as primary...')
            Start-Sleep -s '1'
            Add-AdGroupMember $limitedAccts -Members $user.objectSid -Credential $SDashCred -ErrorAction SilentlyContinue
            Set-ADUser -Identity $user.objectGUID -Replace @{primaryGroupId = $primaryLimitedAccts.primaryGroupToken } -Credential $SDashCred -ErrorAction SilentlyContinue | Out-Null
            

            #Remove all other memberships beside the Primary
            Write-Host ('Removing all other Group Memberships...')
            Start-Sleep -s '1'
            Get-Aduser $user.objectGUID -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Remove-ADGroupMember -Member $user.objectSid -Confirm:$false -Credential $sDashCred


            ######################
            #   License Removal  #
            ######################

            #AzureAD Connect
            $AzureCred = Get-Credential -Username $AzureLogin -Message 'Enter password for modifying Office 365 licenses.'
            
            #Azure Connection Error Check
            $retryLoop = 0
            $stopLoop = $false
            while($stopLoop -eq $false) {
                try {
                    Connect-AzureAD -Credential $AzureCred -errorAction Stop
                    Write-Host 'Connecting to Azure AD Module...'
                    Start-Sleep -s '1'

                    Connect-MsolService -Credential $AzureCred -ErrorAction Stop
                    Write-Host 'Connecting to MSOL Module'
                    Start-Sleep -s '1'

                    $stopLoop = $true
                } catch {
                    Write-Host 'Username or Password is incorrect.'
                    Continue
                } finally {
                    if($retryLoop -ge 2) {
                        $stopLoop = $true
                    } else {
                        $retryLoop++ 
                    }
                }
            }

            #Unassign all licensing on user
            $newLicense = (Get-MsolAccountSku | ForEach-Object {$_ | Where-Object { $_.AccountSkuId -match 'STANDARDPACK' } }).AccountSkuId
            $licenseToRemove = Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Select-Object -ExpandProperty licenses | ForEach-Object { $_ | Where-Object { $_.AccountSkuId -ne "harborwholesale:STANDARDPACK" } }
            Write-Host('Removing all licenses from ' + $user.name + '...')
            Set-AzureADUser -ObjectId $user.userPrincipalName -UsageLocation US
            Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicense $licenseToRemove.AccountSkuId -AddLicenses $newLicense | Out-Null -erroraction SilentlyContinue
            Start-Sleep -s '1'

            <#Assign limited E1 License to User
            Write-Host('Assigning limited licenses...')
            Start-Sleep -s '1'
            
            $SkuFeaturesToEnable = @("SHAREPOINTSTANDARD", "EXCHANGE_S_STANDARD")
            $StandardLicense = Get-AzureADSubscribedSku | Where-Object { $_.SkuId -eq "18181a46-0d4e-45cd-891e-60aabd171b4e" }
            $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where-Object { $_.ServicePlanName -notin $SkuFeaturesToEnable } }
            $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $License.SkuId = $StandardLicense.SkuId
            $License.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
            $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $LicensesToAssign.AddLicenses = $License
            Set-AzureADUserLicense -ObjectId $user.userPrincipalName -AssignedLicenses $LicensesToAssign | Out-Null #>
        } else {
            Return 'Error'
        }

        Get-ADuser -filter "Name -eq 'Rusty Shacklford'" -Properties MemberOf,PrimaryGroup,Enabled,Name | Select-Object Name,Enabled,PrimaryGroup,MemberOf,DistinguishedName | Format-List
        $SuccessfullyDisabledUser = $true
        Read-Host -Prompt 'Press any key to Exit'
        Disconnect-AzureAD | Out-Null
        
    } Until ($SuccessfullyDisabledUser -eq $true)
} 

<# 
***********************************************************************************************************************
This code block below allows *theoretically* the ability to both assign and unassign a license to avoid periods of
time, however I cannot seem to unassign SPE-E3 and assign STANDARDPACK type license simultaneously due to a conflict
with Exchange and Sharepoint services overlapping between the two licenses. 

The license object holds "Add License" and "Remove License" properties, in theory you set the license using this object
and both fields are applied. 
#######################################################################################################################

$subscriptionTo="SHAREPOINTSTANDARD","EXCHANGE_S_STANDARD"
$s = get-msoluser -UserPrincipalName $user.UserPrincipalName | select -ExpandProperty Licenses 
$subscriptionFrom = '"' + ($s -join '","') + '"'

# Unassign

$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$license.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $subscriptionFrom -EQ).SkuID
$licenses.AddLicenses = $license
Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
$licenses.AddLicenses = @()
$licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $subscriptionFrom -EQ).SkuID
Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
# Assign
$license.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $subscriptionTo -EQ).SkuID
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licenses.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
#>


    # for loop to see all licenses that are not STANDARD PACKAGE
    # Add E1 first, then remove all others
    # $Host.UI.RawUI.ForegroundColor = 'Green'