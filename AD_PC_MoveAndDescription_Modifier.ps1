
$pcName = Read-Host -prompt 'Enter the device name'
$pcAssetNum = Read-Host -Prompt 'Enter NAV Asset Number'
$pcModel = Read-Host -Prompt 'Enter the device model'
#$pcModel = $pcModel = (Get-WmiObject -Class win32_computerSystem -property Model | Select-Object model | Out-String)[32 .. 44] -join "" 
$pcSerial = Read-Host -Prompt 'Enter the device Serial number'
#$pcSerial = ((&wmic bios get serialnumber) | Out-String)[18 .. 24] -join ""
$pcUserName = Read-Host -Prompt 'Who is this device for?'
$pcDisName = (Get-ADComputer $pcName).distinguishedName


set-adcomputer -Identity $pcDisName -Description ($pcModel + "** S/T: "+$pcSerial + "** Asset: " + $pcAssetNum + "** (" + $pcUserName + ")")


switch ($pcName)
{
	{$_ -match 'LDC'} {
		
		switch ($pcName.trim('LDC')) {
			{$_ -match '-AP-'} {
				write-host $pcName 'is an Accounts Payable workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Accounts Payable,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-AR-'} {
				write-host $pcName 'is an AR workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Accounts Payable,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-CONF-'} {
				write-host $pcName 'is a CONF workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Accounts Receivable,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-EXEC-'} {
				write-host $pcName 'is an EXEC workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Executive,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-HR-'} {
				write-host $pcName 'is an HR workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=HR,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-IT-'} {
				write-host $pcName 'is an IT workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=IT,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-MKT-'} {
				write-host $pcName 'is an MKT workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Marketing,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-OE-'} {
				write-host $pcName 'is an OE workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Order Entry,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-PUR-'} {
				write-host $pcName 'is an PUR workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Purchasing,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-SLS-'} {
				write-host $pcName 'is an SLS workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Sales,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-SHOP-'} {
				write-host $pcName 'is an SHOP workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Shop,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-TRNS-'} {
				write-host $pcName 'is an TRNS workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU= Transportation,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}

			{$_ -match '-WHS-'} {
				write-host $pcName 'is an WHS workstation'
				Move-AdObject -Identity $pcDisName -TargetPath 'OU=Warehouse,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}
		}
	}

	{$_ -match 'RDC'} {
		switch ($pcName.trim('RDC')) {
			{$_ -match '-CONF-'} {
					write-host $pcName 'is Conference Room workstation'
					Move-AdObject -Identity $pcDisName -TargetPath 'OU=Conference
						Rooms,OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}
			{$_ -match '-GO-'} {
					write-host $pcName 'is an Office workstation'
					Move-AdObject -Identity $pcDisName -TargetPath 'OU=Office,
					OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}
			{$_ -match '-SLS-'} {
					write-host $pcName 'is a Sales workstation'
					Move-AdObject -Identity $pcDisName -TargetPath 'OU=Sales,
					OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}
			{$_ -match '-WHS-'} {
					write-host $pcName 'is a Warehouse workstation'
					Move-AdObject -Identity $pcDisName -TargetPath 'OU=Warehouse,
					OU=Workstations,OU=LDC,OU=HarborWholesale,DC=harborfoods,DC=com'
			}
		}

	}
	Default {

		"Cannot find OU Workstation Folder match. Please move manually."
	}
}