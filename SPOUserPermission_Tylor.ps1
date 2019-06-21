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

##Tylor's Credntiuoals
#$sUserName="abyrdty@adient.com"
#$sMessage="SPO Credential Please"
#$sSPOAdminCenterUrl="https://o365spo-admin.adient.com"
#$sselectedsitecollurl = "https://connect.adient.com/sites/DC-BOS/"

$sUserName="sanjay@brspdev.onmicrosoft.com"
$sMessage="SPO Credential Please"
$sSPOAdminCenterUrl="https://brspdev-admin.sharepoint.com"
$sselectedsitecollurl="https://brspdev.sharepoint.com/sites/BRDev"

function Get-SPOUsersAllSiteCollections
{
    param ($sUserName,$sMessage,$sselectedsitecollurl)

    try
    {
        Write-Host "----------------------------------------------------------------------------" -foregroundcolor Green
        Write-Host "Getting the information for all the site colletions in the Office 365 tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------" -foregroundcolor Green

        $msolcred = get-credential -UserName $sUserName -Message $sMessage

        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

        $spoSites=Get-SPOSite -Limit All | Select *

        foreach($spoSite in $spoSites)
        {
            if($spoSite.Url -eq $sselectedsitecollurl)
            {
                Write-Host "Users for " $spoSite.Url -foregroundcolor Green
                
                Write-Host “Display Name`tLoginName`tGroups`tGroupPermissions”
                “Display Name`tLoginName`tGroups`tGroupPermissions” | Out-File C:\Users\spadmin\Desktop\UsersReport.csv
                $UserColl = Get-SPOUser -Site $spoSite.Url

                Foreach($User in $UserColl)
                {
                    $GroupColl = $User.Groups
                    $GroupPermissions=""
                    Foreach($Group in $GroupColl)
                    {
                        #Get Permissions assigned to the Group
                        $grouproles = Get-SPOSiteGroup -Site $spoSite.Url | Where { $_.Title -eq $Group}
                        $GroupPermissions+=$grouproles.Roles+","
                    }
                
                    Write-Host $User.DisplayName“`t”$User.LoginName“`t”$User.Groups“`t”$GroupPermissions
                    $User.DisplayName + “`t” + $User.LoginName + “`t” + $User.Groups + “`t” + $GroupPermissions| Out-File C:\Users\spadmin\Desktop\UsersReport.csv -Force -Append
                }
            }
        }
    }
    catch [System.Exception]
    {
        Write-Host -f red $_.Exception.ToString() 
    }
}

Get-SPOUsersAllSiteCollections -sUserName $sUserName -sMessage $sMessage -sselectedsitecollurl $sselectedsitecollurl