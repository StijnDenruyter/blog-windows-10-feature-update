$DeviceName				= $Args[0]
$DeviceCollectionName	= $Args[1]
$MEMCMSiteCodeName		= "S01"
$MEMCMSiteServerName	= "MEMCMSERVER.LOCAL"

Try {	
	If (-Not(Get-Module -Name "ConfigurationManager")) {
		If (Test-Path -Path "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1") {
			Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
			If (-Not(Get-Module -Name "ConfigurationManager")) {
				Throw
			}
		}
		Else {
			Throw
		}
	}
	If (-Not($MEMCMSiteCodeName[-1] -eq ":")) {
		$MEMCMSiteCodeNameWithSuffix = "$($MEMCMSiteCodeName):"
	}
	Else {
		$MEMCMSiteCodeNameWithSuffix = $MEMCMSiteCodeName
		$MEMCMSiteCodeName = $MEMCMSiteCodeName -Replace ".$"
	}
	$Result = Get-PSDrive -Name $MEMCMSiteCodeName -ErrorAction SilentlyContinue
	If (-Not($Result)) {
		New-PSDrive -Name $MEMCMSiteCodeName -PSProvider "AdminUI.PS.Provider\CMSite" -Root $MEMCMSiteServerName -Description "MEMCM Site Server" | Out-Null
	}
	Set-Location -Path $MEMCMSiteCodeNameWithSuffix
	$Device = Get-CMDevice -Name $DeviceName
	$DeviceCollection = Get-CMDeviceCollection -Name $DeviceCollectionName
	If ($Device -and $DeviceCollection) {
		Add-CMDeviceCollectionDirectMembershipRule -CollectionId $DeviceCollection.CollectionID -ResourceId $Device.ResourceID
	}
	Else {
		Throw
	}
	Exit 0
}
Catch {
	Exit 1
}