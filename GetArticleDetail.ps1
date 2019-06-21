Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

function GetArticleDetail() {

    param ($sUserName,$sMessage)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the information for all the site colletions in the Office 365 tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        $sUserName = "smit@smitshah.onmicrosoft.com"
        $sPassword = "admin@123"
        $sMessage = "null"
        $sSPOAdminCenterUrl = "https://smitshah-admin.sharepoint.com"
        $sSiteURL = "https://smitshah.sharepoint.com/sites/DevCommSite"
        $ListName = "SitePages"
        
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $sUserName, $(convertto-securestring $sPassword -asplaintext -force)
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $cred

        $spoSites=Get-SPOSite | Select * 
        foreach($spoSite in $spoSites)
        {
            if ($spoSite.Url -eq $sSiteURL)
            {
                Write-Host $spoSite.Url -foregroundcolor Yellow
                
                $Context = New-Object Microsoft.SharePoint.Client.ClientContext($spoSite)
                $Context.Credentials = $cred

                $List = $Context.web.Lists.GetByTitle($ListName)
                
                Write-Host $List
            }
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

$sUserName="smit@smitshah.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://smitshah-admin.sharepoint.com/"

GetArticleDetail -sUserName $sUserName -sMessage $sMessage