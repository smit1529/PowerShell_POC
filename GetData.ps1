#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

Add-Type -path 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll'
Add-Type -path 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll'

function GetData() {

#Variables for Processing
$SiteUrl = "https://smitshah.sharepoint.com/sites/DevCommSite"
$ListName = "Site Pages"
 
$UserName="smit@smitshah.onmicrosoft.com"
$Password ="admin@123"

#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $credentials

$List = $Context.web.Lists.GetByTitle($ListName)

Write-Host $List

$RootFolder = $List.RootFolder

Write-Host $RootFolder

$Context.Load($List)
$Context.Load($RootFolder)
$Context.Load($RootFolder.Folders)

$Context.ExecuteQuery()

Write-Host $RootFolder.Name 

}

GetData