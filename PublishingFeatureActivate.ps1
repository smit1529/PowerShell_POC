#Load SharePoint Online CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
 #Feature ID
 #Disable-SPOFeature –Identity "F6924D36-2FA8-4f0b-B16D-06B7250180FA" -Scope Site
#Disable-SPOFeature –Identity "AEBC918D-B20F-4a11-A1DB-9ED84D79C87E" -Scope Site
#Disable-SPOFeature –Identity "22A9EF51-737B-4ff2-9346-694633FE4416" -Scope Web
#Disable-SPOFeature –Identity "D3F51BE2-38A8-4e44-BA84-940D35BE1566" -Scope Site
#Disable-SPOFeature –Identity "94C94CA6-B32F-4da9-A9E3-1F3D343D7ECB" -Scope Web
 
#Enable-SPOFeature –Identity "F6924D36-2FA8-4f0b-B16D-06B7250180FA" -Scope Site
#Enable-SPOFeature –Identity "AEBC918D-B20F-4a11-A1DB-9ED84D79C87E" -Scope Site
#Enable-SPOFeature –Identity "22A9EF51-737B-4ff2-9346-694633FE4416" -Scope Web
#Enable-SPOFeature –Identity "D3F51BE2-38A8-4e44-BA84-940D35BE1566" -Scope Site
#Enable-SPOFeature –Identity "94C94CA6-B32F-4da9-A9E3-1F3D343D7ECB" -Scope Web
 
#Function to Enable Feature in SharePoint Online
Function Enable-SPOFeature
{
    param ($SiteCollURL,$UserName,$Password,$FeatureGuid)
    Try
    {    
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteCollURL)
        $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username, $Password)
        $Ctx.Credentials = $Credentials
        #$Site=$Ctx.Site
        $Site=$Ctx.web
 
        #Check the Feature Status
        $FeatureStatus =  $Site.Features.GetById($FeatureGuid)
        $FeatureStatus.Retrieve("DefinitionId")
        $Ctx.Load($FeatureStatus)
        $Ctx.ExecuteQuery()
 
        #Activate the feature if its not enabled already
        if($FeatureStatus.DefinitionId -eq $null)
        {
            Write-host "Feature is InActive on the Site collection!" -ForegroundColor Red

            Write-Host "Disabling Feature $FeatureGuid..." -ForegroundColor Yellow
            $Site.Features.Add($FeatureGuid, $false, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None) | Out-Null
            $Ctx.ExecuteQuery()
            Write-Host "Feature Disabled on site $SiteCollURL!" -ForegroundColor Green
        }
        else
        {
            Write-host "Feature is Already Active on the Site collection!" -ForegroundColor Red
        }
    }
    Catch
    {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
}
  
#Parameters to Activate Feature
$SiteCollURL = "https://sshah.sharepoint.com/sites/DevCommSite"
$UserName = "smit@sshah.onmicrosoft.com"
$Password = "Admin@123"
$FeatureGuid= [System.Guid] ("f6924d36-2fa8-4f0b-b16d-06b7250180fa") #Publishing site Feature
#$FeatureGuid= [System.Guid] ("94C94CA6-B32F-4da9-A9E3-1F3D343D7ECB") #Publishing web Feature
$SecurePassword= ConvertTo-SecureString $Password –asplaintext –force 
 
#Enable Feature
Enable-SPOFeature -SiteCollURL $SiteCollURL -UserName $UserName -Password $SecurePassword -FeatureGuid $FeatureGuid


#Read more: http://www.sharepointdiary.com/2015/01/sharepoint-online-activate-feature-using-powershell.html#ixzz5VhHxhFdD