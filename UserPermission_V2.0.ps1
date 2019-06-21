#################################################################

# Script that allows to get all the users for all the Site Collections in a SharePoint Online Tenant

# Required Parameters:

#  -> $sUserName: User Name to connect to the SharePoint Admin Center.

#  -> $sMessage: Message to show in the user credentials prompt.

#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url

#  -> $sselectedsitecollurl : SharePoint Site Collection url


##################################################################


$host.Runspace.ThreadOptions = "ReuseThread"


#Definition of the function that gets all the site collections information in a SharePoint Online tenant
#Connection to Office 365

#$sUserName="abyrdty@adient.com"
#$sMessage="SPO Credential Please"
#$sSPOAdminCenterUrl="https://o365spo-admin.adient.com"
#$sselectedsitecollurl = "https://connect.adient.com/sites/DC-BOS/"

$sUserName="sanjay@brspdev.onmicrosoft.com"
$sMessage="SPO Credential Please"
$sSPOAdminCenterUrl="https://brspdev-admin.sharepoint.com"
$sselectedsitecollurl = "https://brspdev.sharepoint.com/sites/BRDev"
$filePathName = "C:\BR\Documents\PowerShell\9_UsersReport.csv"

function Get-SPOUsersAllSiteCollections
{
	param ($sUserName,$sMessage,$sselectedsitecollurl)
	try
	{
        $matchCount = "false"

		Write-Host "----------------------------------------------------------------------------" -foregroundcolor Green
		Write-Host "Getting the information for all the site colletions in the Office 365 tenant" -foregroundcolor Green
		Write-Host "----------------------------------------------------------------------------" -foregroundcolor Green

		$msolcred = get-credential -UserName $sUserName -Message $sMessage

		Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

		$spoSites = Get-SPOSite -Limit All | Select *

		foreach($spoSite in $spoSites)
		{
			if($spoSite.Url -eq $sselectedsitecollurl)
			{
                $matchCount = "true"
				Write-Host "Users for " $spoSite.Url -foregroundcolor Green

				#“Display Name`tLoginName`tGroups`tGroupPermissions” | Out-File C:\BR\Documents\UsersReport.csv
                “Display Name`tLoginName`tGroups`tGroupPermissions” | Out-File $filePathName
				$UserColl = Get-SPOUser -Site $spoSite.Url

				Foreach($User in $UserColl)
				{
					$GroupColl = $User.Groups
					$GroupPermissions=""
                    $tmpGroups = ""
					Foreach($Group in $GroupColl)
					{
						#Get Permissions assigned to the Group
						$grouproles = Get-SPOSiteGroup -Site $spoSite.Url | Where { $_.Title -eq $Group}
						$GroupPermissions+=$grouproles.Roles+", "
                        $tmpGroups+=$Group+", "
					}

					#$User.DisplayName + “`t” + $User.LoginName + “`t” + $User.Groups + “`t” + $GroupPermissions| Out-File C:\BR\Documents\UsersReport.csv -Force -Append
                    $User.DisplayName + “`t” + $User.LoginName + “`t” + $tmpGroups + “`t” + $GroupPermissions| Out-File $filePathName -Force -Append
				}
			}
		}

        if ($matchCount -eq "false")
        {
            Write-Host "Specified site [" $sselectedsitecollurl "] is not available in [" $sSPOAdminCenterUrl "]" -foregroundcolor Red
        }
        else
        {
            Write-Host "File has been created at the specified location."
        }
	}
	catch [System.Exception]
	{
		Write-Host -f red $_.Exception.ToString() 
	}
}

Get-SPOUsersAllSiteCollections -sUserName $sUserName -sMessage $sMessage -sselectedsitecollurl $sselectedsitecollurl