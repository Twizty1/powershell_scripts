import-module activedirectory
Add-Type -assembly "system.io.compression.filesystem"
function Pause
{
   Read-Host 'Press Enter to continue…' | Out-Null
}

# Get Username and define variables
$UserName = Read-Host "Enter username to be termed"
$TERMER = whoami
$TermUser = get-aduser -filter {SamAccountName -eq $UserName} -Properties DisplayName,Description,distinguishedName,sAMAccountName,Department,Title,HomeDirectory
$Today = get-date -UFormat "%m-%d-%Y"
$BackupDir = "MODIFY WITH DIR PATH FOR BACKUP FOLDER\$($TermUser.SamAccountName)_H-Drive_Termed_$($Today).zip"

#Verify the account exists.
if (!$TermUser) {
  Write-Warning "This username does not exist"
  Pause
  exit
  }
elseif ($TermUser.Enabled -eq $FALSE){
    Write-Host " "
    Write-Warning "Account already disabled."
    Write-Warning "Exiting script..."
    Write-Host " "
    Pause
    exit
    }
else {
#Display information about the user to term and ask to confirm.
Write-Host " "
Write-Host "Terminate the following user:"
Write-Host " "
Write-Host "Name:  $($TermUser.DisplayName)"
Write-Host "Title: $($TermUser.Title)"
Write-Host "Dept:  $($TermUser.Department)"
Write-Host "Distinguished Name: $($TermUser.distinguishedName)"
Write-Host " "
Write-Host " "
Write-Warning "You are about disable this account, please confirm."
Write-Host " "
$Confirm = Read-Host "Y or N"

#If DN isn't empty and Confirmed, move to Disabled OU and disable account.
    if ($TermUser.distinguishedName -ne $NULL -and $Confirm -eq "Y"){
    Write-Host " "
    Write-Host "Moving user to Disabled Users OU"
    move-adobject -Identity "$($TermUser.distinguishedName)" -TargetPath "MODIFY WITH DESTINATION OU IN DN FORMAT"
    Write-Host " "
    Write-Host "Setting account to Disabled"
    disable-adaccount -identity "$($TermUser.SamAccountName)"
    Write-Host " "
    Write-Host "Updating user description"
    set-aduser -identity $($TermUser.sAMAccountName) -Description "$($TermUser.Description) TERMED BY $($TERMER) on $(Get-Date)."
    }
    elseif ($Confirm -ne "Y"){
    Write-Host " "
    Write-Warning "Not confirmed.  Exiting script."
    Pause
    exit
    }
    else{
    Write-Host " "
    Write-Warning "Not a valid entry.  Exiting."
    Pause
    Exit
    }
}

#Look for users Home Drive.  If exists, zip and move to TERMED folder.
if (Test-Path $TermUser.HomeDirectory) {
    Write-Host " "
    Write-Host "Compressing users home directory..."
	[io.compression.zipfile]::CreateFromDirectory($TermUser.HomeDirectory, $BackupDir)
    }
    else {
        Write-Host " "
	    Write-Warning "Home directory does not exist.  Exiting."
	    Write-Host " "
        Pause
        exit
	}
#Verify zip file has been created and delete Home Drive.
if (Test-Path $BackupDir) {
    Write-Host "Deleting users H drive from DFS"
	remove-item -path $TermUser.HomeDirectory -Recurse
	}
else {
    Write-Host " "
	write-warning "Zip file does not exist.  Exiting."
    Pause
    exit
	}
