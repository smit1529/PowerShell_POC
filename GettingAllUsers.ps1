############################################################################################################################################
# Script that allows to get all the users for all the Site Collections in a SharePoint Online Tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the site collections information in a SharePoint Online tenant
function Get-SPOUsersAllSiteCollections
{
    param ($sUserName,$sMessage)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the information for all the site colletions in the Office 365 tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        $sUserName = "sanjay@brspdev.onmicrosoft.com"
        $sPassword = "binary@Dev"
        $sMessage = "null"
        $sSPOAdminCenterUrl = "https://brspdev-admin.sharepoint.com"
        $sSiteURL = "https://brspdev.sharepoint.com/sites/BRDev"

        
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $sUserName, $(convertto-securestring $sPassword -asplaintext -force)
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $cred

        #$msolcred = get-credential -UserName $sUserName -Message $sMessage 
        #Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

        $spoSites=Get-SPOSite | Select * 
        foreach($spoSite in $spoSites)
        {
            if ($spoSite.Url -eq $sSiteURL)
            {
                Write-Host "Users for " $spoSite.Url -foregroundcolor Yellow
                #Get-SPOUser -Site $spoSite.Url
                #Write-Host
                $sUsers = Get-SPOUser -Site $spoSite.Url
                foreach($sUser in $sUsers)
                {
                    Write-Host $sUser.LoginName"-"$sUser.IsSiteAdmin                    
                    if($sUser.issiteadmin)
                    {
                        #Export-SPOUserInfo -LoginName $sUser.LoginName -site $sSiteURL -OutputFolder "C:\exportfolder"

                        #$permissionInfo = $spoSite.GetUserEffectivePermissionInfo($sUser)
                        #Write-Host $permissionInfo -foregroundcolor Green
                        #$roles = $permissionInfo.RoleAssignments
                        #Write-Host $roles -foregroundcolor Green
                    }
                }
            }        
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="sanjay@brspdev.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://brspdev-admin.sharepoint.com/"

Get-SPOUsersAllSiteCollections -sUserName $sUserName -sMessage $sMessage



