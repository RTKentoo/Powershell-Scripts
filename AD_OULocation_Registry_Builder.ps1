

$hostname = $env:computername
$splitOU = (Get-ItemProperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine').'Distinguished-Name'.split(",")
$startIndex = $splitOU.length - ($splitou.length-1)
$i=0

#Find the OU 'DC=' and start at the index just past it (the first 'OU=')
foreach ($ou in $splitou) {
	if ($ou -match 'DC=' -AND $i -gt 0) {
		$endIndex = $splitOU.indexof($splitOU[$i-1])
		break
	}
	elseif ($ou -match 'DC=' -AND $i -eq 0) {
		$endIndex = $splitOU.indexOf($i)
		break
	}
	$i++
}

#Output Field Seperator used to Stringify array with spaces between OU's. Default is "". 
$OFS=" "; $stringOU = [string]($splitOU[ $startIndex .. $endIndex ])

Set-Location 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine'

Set-ItemProperty -Path '.\' -Name 'OU Location' -Value $stringOU