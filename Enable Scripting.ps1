$adminUPN="v-justin.thomason@gly.onmicrosoft.com"

$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."

Connect-SPOService -Url https://gly-admin.sharepoint.com -Credential $userCredential

set-sposite https://gly.sharepoint.com/sites/PrincipalAwards -denyaddandcustomizepages $false