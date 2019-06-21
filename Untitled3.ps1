function Get-SPOListView
{
    param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$Username,
    [Parameter(Mandatory=$true,Position=2)]
    $AdminPassword,
    [Parameter(Mandatory=$true,Position=3)]
    [string]$Url,
    [Parameter(Mandatory=$true,Position=4)]
    [string]$ListTitle
    )

    $ctx=New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username, $AdminPassword)
    $ll=$ctx.Web.Lists.GetByTitle($ListTitle)

    #$Url.AllowUnsafeUpdates = $true

    $ctx.load($ll) 
    $ctx.ExecuteQuery()

    $qry = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
    $items = $ll.GetItems($qry)
    $ctx.Load($items)
    $ctx.ExecuteQuery()

    foreach($listItem in $items)
    {
        Write-Host "ID - " $listItem["ID"] "Title - " $listItem["Title"] "Body - " $listItem["Body"]

        if ($listItem["ID"] -eq "4")
        {
            Write-Host "Created on - " $listItem["Created"]

            $listItem["Modified"] = "1/15/2018 1:15:18 PM"
            $listItem["Created"] = "1/15/2018 1:15:18 PM"

            $listItem.Update()

            $ctx.ExecuteQuery()

            Write-Host "ID - " $listItem["ID"] "Title - " $listItem["Title"] "Created on - " $listItem["Created"]
        }
    }
}

# Paths to SDK. Please verify location on your computer.
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 

# Insert the credentials and the name of the admin site
$Username="sanjay@brspdev.onmicrosoft.com"
$AdminPassword=Read-Host -Prompt "Password" -AsSecureString
$AdminUrl="https://brspdev.sharepoint.com/sites/UMC"
$ListTitle="Site Pages"

Get-SPOListView -Username $Username -AdminPassword $AdminPassword -Url $AdminUrl -ListTitle $ListTitle