$CurrentDirPath = Split-Path $script:MyInvocation.MyCommand.Path
$ImageFolder = "$CurrentDirPath\Images\"
Get-ChildItem -Path $ImageFolder -File -Force -ErrorAction SilentlyContinue | Remove-Item

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
[System.Reflection.Assembly]::LoadFrom("$CurrentDirPath\Microsoft.SharePoint.Client.dll")
[System.Reflection.Assembly]::LoadFrom("$CurrentDirPath\Microsoft.SharePoint.Client.Runtime.dll")
[System.Reflection.Assembly]::LoadFrom("$CurrentDirPath\Microsoft.SharePoint.Client.UserProfiles.dll")
Add-Type -AssemblyName System.Drawing

#Error log file path and name
$FilePath = "$CurrentDirPath\UMC_erroInfo.txt";

# SharePoint Online Central Admin Site Collection URL
$sSiteUrl = “https://umc1920-admin.sharepoint.com/”

# My Site URL
$mySiteUrl= "https://umc1920-my.sharepoint.com/"

# Tenant Administrator Username
$sUserName = “7soft1@umci.com”

# Tenant Administrator password
$sPassword = "Th37s0ft1" #Read-Host -assecurestring "Please enter password"

# Claims membership prefix
$UserProfilePrefix = “i:0#.f|membership|”

# Read the Admin user’s credentials
$credential = New-Object System.Management.Automation.PsCredential($sUserName,$sPassword)

# Clear the screen
Cls

#functions to upload images to User Profiles
Function UploadImage()
{
	Param(
	  [Parameter(Mandatory=$True)]
	  [String]$SiteURL,

	  [Parameter(Mandatory=$True)]
	  [System.Net.ICredentials]$SPOCreds,
	
	  [Parameter(Mandatory=$True)]
	  [String]$ImagePath,

	  [Parameter(Mandatory=$True)]
	  [String]$SPOAdminPortalUrl

	)

	#Default Image library and Folder value 
	$DocLibName ="User Photos"
	$foldername="Profile Pictures"

	#$Securepass = ConvertTo-SecureString $Password -AsPlainText -Force
	#$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Securepass)


	#Bind to site collection
	$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$Context.Credentials = $SPOCreds

	#Retrieve list
	$List = $Context.Web.Lists.GetByTitle($DocLibName)
	$Context.Load($List)
	$Context.Load($List.RootFolder)
	$Context.ExecuteQuery()
	$ServerRelativeUrlOfRootFolder = $List.RootFolder.ServerRelativeUrl

	$uploadFolderUrl=  $ServerRelativeUrlOfRootFolder+"/"+$foldername
	$spoimagename = @{"_SThumb" = "48"; "_MThumb" = "72"; "_LThumb" = "200"}
	#Upload file
	#Foreach ($File in (dir $Folder -File))
	#{
		#if ($File.FullName -like '*ps1*') { continue; }

		#Upload image into Exchange online 
        $File = Get-Item $ImagePath
        $PictureData = $File.FullName
		$Identity=$File.BaseName

		$username=$File.BaseName.Replace("@", "_").Replace(".", "_")
		$Extension = $File.Extension
		Foreach($imagename in $spoimagename.GetEnumerator())
		{
			#Covert image into different size of image
			$img = [System.Drawing.Image]::FromFile((Get-Item $PictureData))
			    
            if($imagename.Value -ne "200") {
                [int32]$new_width = $imagename.Value
                [int32]$new_height = $imagename.Value }
    
            else {
                [int32]$new_width = $img.Width
	            [int32]$new_height = $img.Height }

			$img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)
			$graph = [System.Drawing.Graphics]::FromImage($img2)
			$graph.DrawImage($img, 0, 0, $new_width, $new_height)

			#Covert image into memory stream
			$stream = New-Object -TypeName System.IO.MemoryStream
			$format = [System.Drawing.Imaging.ImageFormat]::Jpeg
			$img2.Save($stream, $format)
			$streamseek=$stream.Seek(0, [System.IO.SeekOrigin]::Begin)

			#Upload image into SharePoint online
			$FullFilename=$username+$imagename.Name+$Extension
			$ImageRelativeURL="/"+$DocLibName+"/"+$foldername+"/"+$FullFilename
			$ModifiedRelativeURL=$ImageRelativeURL.Replace(" ","%20")
			[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($Context,$ModifiedRelativeURL, $stream, $true)
            
            $img2.Dispose()
            $stream.Close()
		}
		Write-Host "Photo is uploaded in User Profile Library in SharePoint Online for - " $Identity 
		#Change user Profile Property in SharePoint online 
		$PictureURL=$SiteURL+$DocLibName+"/"+$foldername+"/"+$username+"_MThumb"+$Extension

		UpdateUserProfile -targetAcc $Identity  -PropertyName PictureURL  -Value $PictureURL -SPOAdminPortalUrl $SPOAdminPortalUrl -Creds $SPOCreds

		UpdateUserProfile -targetAcc $Identity  -PropertyName SPS-PicturePlaceholderState -Value 0 -SPOAdminPortalUrl $SPOAdminPortalUrl -Creds $SPOCreds

		UpdateUserProfile -targetAcc $Identity  -PropertyName SPS-PictureExchangeSyncState -Value 0 -SPOAdminPortalUrl $SPOAdminPortalUrl -Creds $SPOCreds

		UpdateUserProfile -targetAcc $Identity  -PropertyName SPS-PictureTimestamp  -Value 63605901091 -SPOAdminPortalUrl $SPOAdminPortalUrl -Creds $SPOCreds

		Write-Host "Profile Photo is processed successfully with all properties and ready to display in SharePoint Online for - " $Identity 
	#}
}

Function UpdateUserProfile()
{
	Param(
	  [Parameter(Mandatory=$True)]
	  [String]$targetAcc,

	  [Parameter(Mandatory=$True)]
	  [String]$PropertyName,

	  [Parameter(Mandatory=$False)]
	  [String]$Value, 

	  [Parameter(Mandatory=$True)]
	  [String]$SPOAdminPortalUrl,

	  [Parameter(Mandatory=$True)]
	  [System.Net.ICredentials]$Creds

	)
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SPOAdminPortalUrl)
	$ctx.Credentials = $Creds
	$peopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($ctx)
	$targetAccount = ("i:0#.f|membership|" + $targetAcc)
	$peopleManager.SetSingleValueProfileProperty($targetAccount, $PropertyName, $Value)
	$ctx.ExecuteQuery()
    Write-Host $PropertyName + " : " + $Value " is processed successfully for - " $targetAcc
}

#Connect with Azure AD - will ask for credentials in popup.
Connect-AzureAD -Credential $credential

# Connect to Exchange Online
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri “https://outlook.office365.com/powershell-liveid/” -Credential $credential -Authentication “Basic” –AllowRedirection
Import-PSSession $exchangeSession

# Get the list of All Users who are having Birthday (AD field - CustomAttribute1) and HireDate (AD field - CustomAttribute2) is set in Exchange/Azure & Local AD)
$users = Get-Mailbox -ResultSize unlimited -Filter { CustomAttribute1 -ne $null -or CustomAttribute2 -ne $null -or CustomAttribute3 -ne $null }

# Output the number of users
Write-Host “Found $($users.Length) employees to process”

# Set counts
$count = 0
$total = $users.Length

write-host $total

# Create SP Client Context of SharePoint Online Central Admin Site
$spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
$spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)
$spoCtx.Credentials = $spoCredentials

#Initialize a new instance of PeopleManager Object
$peopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($spoCtx)

# Loop through the All Users to update the fields
$users | ForEach-Object {
    
	# Output the current progress
    $count = $count + 1
    $percent = ($count * 100 / $total) -as [int]
    Write-Progress -Activity “Processing employees” -Status “Processing $($_.DisplayName)…” -PercentComplete $percent

    # Get the UserName, CustomAttribute1 - Birthday, CustomAtrribute2 - HireDate, CustomAtrribute3 - Extension, MobilePhone & Photo)
    $userName = $_.UserPrincipalName
    $birthDay = $_.CustomAttribute1 #dd-MMM
    $hireDate = $_.CustomAttribute2 #MM/dd/yyyy
    $extension= $_.CustomAttribute3 #123

	$tempUser = Get-User -Identity $userName
	$mobilephone = $tempUser.MobilePhone #1234567890
        
    $azureADUser = Get-AzureADUser -SearchString $userName
    $userObjectId = $azureADUser.ObjectId
    
    # Update Photo field
    try {
        #Get User Photo from Azure Ad and download to local drive.        
        Get-AzureADUserThumbnailPhoto -ObjectId $userObjectId -FilePath ((Get-Item -Path ".\").FullName+"\Images\")
        $FileName = (Get-Item -Path ".\").FullName+"\Images\"+$userObjectId+".*"
        
        Write-Host "$userName - Photo $FileName is downloaded local drive." -ForegroundColor Green

        $FileNameWithExt = (Get-Item $FileName).FullName

        # Check if User Photo exists in local drive.
        if (Test-Path $FileName) {
                
                #Update User Photo field in Exchange Online which auto sync with User Profile.
                Set-UserPhoto -Identity $tempUser.UserPrincipalName -PictureData ([System.IO.File]::ReadAllBytes($FileNameWithExt)) -Confirm:$false;
                Write-Host "$userName photo is uploaded to Exchange Online." -ForegroundColor Green			    
			
                #Rename file name to be with user's UPN (required for SPO Profile).
                Get-Item $FileName | Rename-Item -NewName { $_.name -Replace $userObjectId,$userName }
								
				#Upload Image to SharePoint User Profile.
				UploadImage -SiteURL $mySiteUrl -SPOCreds $spoCredentials -ImagePath ($FileNameWithExt -Replace $userObjectId,$userName) -SPOAdminPortalUrl $sSiteUrl
                Write-Host "$userName photo is ready to display in SharePoint Online." -ForegroundColor Green	
                
            }
        }

    Catch {
            Write-Host "$userName does not have photo is in Azure AD." -ForegroundColor Red
            "------------------------------------------------------------"| Out-File $FilePath -Append
            "DATETIME = " + $(get-date) | Out-File $FilePath -Append
            "ERROR MESSAGE = " + $($_.Exception.Message) + "for " + $userName | Out-File $FilePath -Append 
            "------------------------------------------------------------"| Out-File $FilePath -Append
        }
    
	# Update Birthday field
    If ($birthday -ne $null -and $birthday -ne “”) {
        Try {
            # Format the birthday correctly            
            		    
            $changeFormat = [datetime]::ParseExact($birthDay, "dd-MMM", $null);
            $birthdDate = "{0:MMM dd}" -f [datetime]$changeFormat                   

            # Update the property
            $peopleManager.SetSingleValueProfileProperty($UserProfilePrefix + $userName, “SPS-Birthday”, $birthdDate)
			Write-Host “$userName has valid birthday in CustomAttribute1: $birthDay $birthdDate” -ForegroundColor Green
			
			# Execute our changes
            $spoCtx.ExecuteQuery()
        }
        Catch {
         Write-Host “$userName does not have a valid birthday in CustomAttribute1: $birthDay $birthdDate” -ForegroundColor Red
		 "------------------------------------------------------------"| Out-File $FilePath -Append
         "DATETIME = " + $(get-date) | Out-File $FilePath -Append
         "ERROR MESSAGE = " + $($_.Exception.Message) | Out-File $FilePath -Append 
         "------------------------------------------------------------"| Out-File $FilePath -Append
        }
    }
	
    # Update HireDate field
    If ($hireDate -ne $null -and $hireDate -ne “”) {
        Try {
            # Format the HireDate correctly            
            $spshireDate = [datetime]::ParseExact($hireDate, "MM/dd/yyyy", $null);

            # Update the property
            $peopleManager.SetSingleValueProfileProperty($UserProfilePrefix + $userName, “SPS-HireDate”, $spshireDate)
            Write-Host “$userName has a valid HireDate in CustomAttribute2: $hireDate $spshireDate” -ForegroundColor Green
            
			# Execute our changes
            $spoCtx.ExecuteQuery()
        
        }
        Catch {
         Write-Host “$userName does not have a valid HireDate in CustomAttribute2: $hireDate $spshireDate” -ForegroundColor Red
		 "------------------------------------------------------------"| Out-File $FilePath -Append
         "DATETIME = " + $(get-date) | Out-File $FilePath -Append
         "ERROR MESSAGE = " + $($_.Exception.Message) | Out-File $FilePath -Append 
         "------------------------------------------------------------"| Out-File $FilePath -Append
        }
    }

    # Update Extension field 
    If ($extension -ne $null -and $extension -ne “”) {
        Try {
                        
            # Update the Extension property
            $peopleManager.SetSingleValueProfileProperty($UserProfilePrefix + $userName, “Extension”, $extension)
            Write-Host “$userName has a valid Extension in CustomAttribute3: $extension” -ForegroundColor Green
            
			# Execute our changes
            $spoCtx.ExecuteQuery()
        
        }
        Catch {
         Write-Host “$userName does not have a valid Extension in CustomAttribute3: $extension” -ForegroundColor Red
		 "------------------------------------------------------------"| Out-File $FilePath -Append
         "DATETIME = " + $(get-date) | Out-File $FilePath -Append
         "ERROR MESSAGE = " + $($_.Exception.Message) | Out-File $FilePath -Append 
         "------------------------------------------------------------"| Out-File $FilePath -Append
        }
    }
		
	# Update Mobile field 
    If ($mobilephone -ne $null -and $mobilephone -ne “”) {
       Try {
                        
          # Update the property
          $peopleManager.SetSingleValueProfileProperty($UserProfilePrefix + $userName, “CellPhone”, $mobilephone)
       
         Write-Host “$userName has a valid Mobile No in mobile: $mobilephone" -ForegroundColor Green
            
			# Execute our changes
        $spoCtx.ExecuteQuery()
        
       }
        Catch {
         Write-Host “$userName does not have a valid Mobile in mobile: $mobilephone" -ForegroundColor Red
		 "------------------------------------------------------------"| Out-File $FilePath -Append
         "DATETIME = " + $(get-date) | Out-File $FilePath -Append
         "ERROR MESSAGE = " + $($_.Exception.Message) | Out-File $FilePath -Append 
         "------------------------------------------------------------"| Out-File $FilePath -Append
        }
    }

    #Delete the downloaded photo from local drive.                                
    #Remove-Item ($FileNameWithExt -Replace $userObjectId,$userName)
    #Write-Host ($FileNameWithExt -Replace $userObjectId,$userName)+" is deleted." -ForegroundColor Green
}

# Dispose of the SharePoint Online context
$spoCtx.Dispose()

# Remove the connection to exchange online
Remove-PSSession $exchangeSession