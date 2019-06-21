$adminUPN="smit@smitshah.onmicrosoft.com"

$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."

Connect-SPOService -Url https://smitshah-admin.sharepoint.com -Credential $userCredential

set-sposite https://smitshah.sharepoint.com/sites/DevModernSite -denyaddandcustomizepages $false