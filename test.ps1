Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

function GetData() {

#Variables for Processing
$SiteUrl = "https://smitshah.sharepoint.com/sites/DevCommSite"
$ListName = "Site Pages"
 
$UserName="smit@smitshah.onmicrosoft.com"
$password = Read-Host -Prompt "Enter password" -AsSecureString  

#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,$Password)
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $Credentials
$Context.ExecuteQuery()
Write-Host $Context.web

$web = $Context.web
$Context.Load($web)
$Context.ExecuteQuery()

$List = $web.Lists.GetByTitle($ListName)
$Context.Load($List)
$Context.ExecuteQuery()

if($List.Title -eq "Site Pages")
{
	$PagesUrl = $web.Url + "/"
	foreach($eachPage in $List.Items)
	{
		$data = @{
			"Web" = $web.Url
			"list" = $List.Title
			"Item ID" = $eachPage.ID
			"Item URL" = $eachPage.Url
			"Item Name" = $eachPage.Name
		}
	New-Object PSObject -Property $data
	}
	$web.Dispose();
}

}

#GetData

#Get-Documents | Out-GridView
GetData | Export-Csv -NoTypeInformation -Path C:\Test.csv #Provide you desired path.