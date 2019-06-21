# Provide URL of the Site over here
#$siteURL= "https://vctechnolabs.sharepoint.com/sites/test23"
Add-Type -AssemblyName Microsoft.VisualBasic
$siteURL = [Microsoft.VisualBasic.Interaction]::InputBox("Please Provide URL", "Site URL", "https://smitshah.sharepoint.com/devTest")

#This will prompt to enter credentials
$credentials= Get-Credential

Connect-PnPOnline -Url $siteURL -Credentials $credentials

Write-Host "Connected"

$FeatureId = "915c240e-a6cc-49b8-8b2c-0bff8b553ed3"
#get the Feature
$Feature = Get-PnPFeature -Scope Web -Identity $FeatureId
 
#Get the Feature status
If($Feature.DefinitionId -eq $null)
{   
    #Activate the Feature
    Write-host -f Yellow "Activating Feature..."
    Enable-PnPFeature -Identity $FeatureId -Scope Site -Force 
 
    Write-host -f Green "Feature Activated Successfully!"
}
Else
{
    Write-host -f Yellow "Feature is already active!"
}

$FeatureId = "6e1e5426-2ebd-4871-8027-c5ca86371ead"
If($Feature.DefinitionId -eq $null)
{   
    #Activate the Feature
    Write-host -f Yellow "Activating Feature..."
    Enable-PnPFeature -Identity $FeatureId -Scope Site -Force 
 
    Write-host -f Green "Feature Activated Successfully!"
}
Else
{
    Write-host -f Yellow "Feature is already active!"
}

# "PinIt" Group name for the term group
$TermGroupName = "PinIt"
$TermGroupDescription =""
#Check if Term group exists
If(-Not(Get-PnPTermGroup -Identity $TermGroupName -ErrorAction SilentlyContinue))
{
    #Create new group in Termstore
    New-PnPTermGroup -Name $TermGroupName -Description $TermGroupDescription
    Write-host -f Green "Term Group '$TermGroupName' created successfully!"
}
Else
{
    Write-host -f Yellow "Term Group '$TermGroupName' already exists!"
}

# Term set
$TermSetName="Category"
New-PnPTermSet -Name $TermSetName -TermGroup $TermGroupName 

New-PnPTerm -Name "3D Printing" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Book" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Coding" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Film" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "General" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "PC Robotics" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Virtual Reality" -TermSet $TermSetName -TermGroup $TermGroupName

# Term set
$TermSetName="Resource Type"
New-PnPTermSet -Name $TermSetName -TermGroup $TermGroupName 

New-PnPTerm -Name "Blog" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Document" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Image" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Learning Challenge" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Link" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Professional Learning" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Student Work Sample" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Support" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "Video" -TermSet $TermSetName -TermGroup $TermGroupName

# Term set
$TermSetName="Keywords"
New-PnPTermSet -Name $TermSetName -TermGroup $TermGroupName 

New-PnPTerm -Name "0312636" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312637" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312638" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312639" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312640" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312641" -TermSet $TermSetName -TermGroup $TermGroupName
New-PnPTerm -Name "0312642" -TermSet $TermSetName -TermGroup $TermGroupName





$ListName ="BoardRegister"

#List "BoardRegister" 
New-PnPList -Title $ListName -Url $ListName -Template GenericList -EnableVersioning

Write-Host -f Green "List" $ListName "Created"

#Columns of List "BoardRegister"
Add-PnPField -List $ListName -DisplayName "BoardCardCount" -InternalName "BoardCardCount" -Type Number 

Add-PnPField -List $ListName -DisplayName "Boost" -InternalName "Boost" -Type Number 

Add-PnPTaxonomyField -List $ListName  -DisplayName "Category" -InternalName "Category" -TermSetPath "PinIt|Category"

Add-PnPField -List $ListName -DisplayName "Description" -InternalName "Description" -Type Note -AddToDefaultView

Add-PnPField -List $ListName -Type Boolean -DisplayName "Featured" -InternalName "Featured" -AddToDefaultView

Add-PnPField -List $ListName -DisplayName "GraphicType" -InternalName "GraphicType" -Type Choice -AddToDefaultView -Choices "Image","Video"

Add-PnPField -List $ListName -DisplayName "GraphicURL" -InternalName "GraphicURL" -Type Note -AddToDefaultView

Add-PnPTaxonomyField -List $ListName  -DisplayName "Keyword" -InternalName "Keyword" -TermSetPath "PinIt|Keywords"

Add-PnPField -List $ListName -DisplayName "OriginalId" -InternalName "OriginalId" -Type Number 

Add-PnPField -Type Boolean -List $ListName -DisplayName "Published" -InternalName "Published" -AddToDefaultView

Add-PnPField -List $ListName -DisplayName "ThumbnailURL" -InternalName "ThumbnailURL" -Type Note -AddToDefaultView

$FieldXML= "<Field Type='User' Name='OrgCreator' ID='$([GUID]::NewGuid())' DisplayName='OrgCreator' Required ='FALSE' UserSelectionMode='PeopleAndGroups' Mult='TRUE' ></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List $ListName

Write-Host -f Green "Columns of" $ListName "Created"



#List "BoardsSharedFollowed"
$ListName ="BoardsSharedFollowed"
$choices ="Followed","Shared"

New-PnPList -Title $ListName -Url $ListName -Template GenericList -EnableVersioning

Write-Host -f Green "List" $ListName "Created"

#Columns of list "BoardsSharedFollowed"
Add-PnpField -List $ListName -DisplayName UserID -InternalName UserID -Type Text -AddToDefaultView

Add-PnpField -List $ListName -DisplayName FollowedShared -InternalName FollowedShared -Type Choice -Choices $choices -AddToDefaultView 

$FieldXML= "<Field Type='User' Name='User' ID='$([GUID]::NewGuid())' DisplayName='User' Required ='FALSE' UserSelectionMode='PeopleAndGroups' Mult='TRUE' ></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List $ListName

#Provide List Name of Parent list for Lookup column
$ParentListName = "BoardRegister"
$LookupListID = (Get-PnPList -Identity $ParentListName).ID

$FieldXML= "<Field Type='Lookup' Name='BoardID1' ID='$([GUID]::NewGuid())' DisplayName='BoardID1' List='$LookupListID' ShowField='ID'></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List "BoardsSharedFollowed"

Write-Host -f Green "Columns of" $ListName "Created"



#List "BoardGroups"
$ListName ="BoardGroups"

New-PnPList -Title $ListName -Url $ListName -Template GenericList -EnableVersioning

Write-Host -f Green "List" $ListName "Created"

#Columns of list "BoardsSharedFollowed"
Add-PnPField -DisplayName "GroupSortOrder" -InternalName "GroupSortOrder" -Type Number -List $ListName

Add-PnPField -DisplayName "OrgGroupID" -InternalName "OrgGroupID" -Type Number -List $ListName

Add-PnpField -List $ListName -DisplayName GroupDescription -InternalName GroupDescription -Type Note -AddToDefaultView

#Provide List Name of Parent list for Lookup column
$ParentListName = "BoardRegister"
$LookupListID = (Get-PnPList -Identity $ParentListName).ID

$FieldXML= "<Field Type='Lookup' Name='GroupBoardID' ID='$([GUID]::NewGuid())' DisplayName='GroupBoardID' List='$LookupListID' ShowField='ID'></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List "BoardGroups"

Write-Host -f Green "Columns of" $ListName "Created"




#List "BoardCards"
$ListName ="BoardCards"
New-PnPList -Title $ListName -Url $ListName -Template GenericList -EnableVersioning

Write-Host -f Green "List" $ListName "Created"

#Columns of list "BoardCards"
Add-PnpField -List $ListName -DisplayName BoardCardID -InternalName BoardCardID -Type Text -AddToDefaultView

Add-PnPField -List $ListName -DisplayName "BoardCount" -InternalName "BoardCount" -Type Number 

Add-PnPField -List $ListName -DisplayName "Boost" -InternalName "Boost" -Type Number 

Add-PnPField -List $ListName -DisplayName "CardSortOrder" -InternalName "CardSortOrder" -Type Number 

Add-PnPTaxonomyField -List $ListName  -DisplayName "Category" -InternalName "BoardCardCategory" -TermSetPath "PinIt|Category"

Add-PnpField -List $ListName -DisplayName Description -InternalName Description1 -Type Note -AddToDefaultView

Add-PnPTaxonomyField -List $ListName  -DisplayName "Keyword" -InternalName "Keyword" -TermSetPath "PinIt|Keywords"

Add-PnpField -List $ListName -DisplayName ResourceURL -InternalName ResourceURL -Type Text -AddToDefaultView

Add-PnpField -List $ListName -DisplayName ThumbnailURL -InternalName ThumbnailURL -Type Note -AddToDefaultView

Add-PnPField -Type Boolean -List $ListName -DisplayName "Published" -InternalName "Published" -AddToDefaultView

Add-PnPTaxonomyField -List $ListName  -DisplayName "ResourceType" -InternalName "ResourceType" -TermSetPath "PinIt|Resource Type"


#Provide List Name of Parent list for Lookup column
$ParentListName = "BoardGroups"
$LookupListID = (Get-PnPList -Identity $ParentListName).ID

$FieldXML= "<Field Type='Lookup' Name='GroupID' ID='$([GUID]::NewGuid())' DisplayName='GroupID' List='$LookupListID' ShowField='ID'></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List $ListName

#Provide List Name of Parent list for Lookup column
$ParentListName = "BoardRegister"
$LookupListID = (Get-PnPList -Identity $ParentListName).ID

$FieldXML= "<Field Type='Lookup' Name='BoardID1' ID='$([GUID]::NewGuid())' DisplayName='BoardID1' List='$LookupListID' ShowField='ID'></Field>"

Add-PnPFieldFromXml -FieldXml $FieldXML -List $ListName

Write-Host -f Green "Columns of" $ListName "Created"


$ListName ="Site Configuration"

#List "Site Configuration" 
New-PnPList -Title $ListName -Url $ListName -Template GenericList

Write-Host -f Green "List" $ListName "Created"

#Columns of list "Site Configuration"
Add-PnpField -List $ListName -DisplayName Value -InternalName Value -Type Text -AddToDefaultView

Add-PnPListItem -List $ListName -Values @{"Title"="Unsplash ClientId" ; "Value" = ""}

Write-Host -f Green "Columns of" $ListName "Created"


#Asset Library "PinterestImage" 

$ListName = "PinterestImage"
$ListTemplateName ="Asset Library"
$Ctx = Get-PnPContext
$Lists = $Ctx.Web.Lists
$Ctx.Load($Lists)
$Ctx.ExecuteQuery()


$Web = $Ctx.Web
$ListTemplates = $Ctx.web.listtemplates
$Ctx.Load($Web)
$Ctx.Load($ListTemplates)
Invoke-PnPQuery
$ListTemplate = $ListTemplates | where {$_.Name -eq $ListTemplateName}
 
#sharepoint online powershell create list from template
$ListCreation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListCreation.Title = $ListName
$ListCreation.ListTemplate = $ListTemplate
$Web.Lists.Add($ListCreation)
Invoke-PnPQuery
Write-Host -f Green "Asset library" $ListName "Created"

Disconnect-PnPOnline