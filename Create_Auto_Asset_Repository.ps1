#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
#	Add-PSSnapin "Microsoft.SharePoint.PowerShell"
#}
$User = "smit@smitshah.onmicrosoft.com"
$SiteURL = "https://smitshah.sharepoint.com/devTest"
$ListTitle = "AssetLibDevTest"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds
$Context.ExecuteQuery()
$web = $Context.Web
$Context.load($web)
$Context.ExecuteQuery()
#$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
#clear
#Start-SPAssignment -Global

$listTemplateType = "Asset Library"

#We try to work with the Asset Library
$web.ListTemplates | Where-Object {$_.Name -eq $listTemplateType} | ForEach-Object {
Write-Host ""$_.Name" "$_.Type

#We initialize the values of the list
$title = $ListTitle
$description = "MY DESCRIPTION"
$url = "https://smitshah.sharepoint.com/devTest/Lists/DevTest/AssetLibDevTest"
$featureId = $null
$templateType = $_.Type
$docTemplateType = $null


# we create the list with it's url instead of the title
$newListId = $web.Lists.Add($url, $description, $_)
$newList = $web.Lists[$newListId]

# We change the list's title for the real title instead of the url.
if ($newList -ne $null) {
$newList.Title = $title
$newList.Update()
}
}