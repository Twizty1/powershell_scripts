
import-module activedirectory

#Default password to be used for reset function.
$NewPass = "Password1"

#Pause function
function Pause
{
   Read-Host 'Press Enter to return to menu.' | Out-Null
}

#Get Username, verify exists in AD, output user info and request confirmation of correct user to modify.
function UserInfo
{
#Safety check, verify username exists before moving on.
Do{
    # Get a username from the user
    Clear
    Write-Host " "
    $Username = Read-Host "Enter username"
    Write-Host " "

    Try
    {
    # Check if it's in AD
    $script:UnlockUser = get-aduser -filter {SamAccountName -eq $UserName} -Properties DisplayName,Description,distinguishedName,sAMAccountName,Department,Title,HomeDirectory,LockedOut -ErrorAction Stop
    }
    Catch
    {
    # Couldn't be found
    Write-Warning -Message "Could not find a user with the username: $Username. Please check the spelling and try again."

    # Loop de loop (Restart)
    $Username = $null
    }
}
While ($Username -eq $null)

#After safety checks, output information of the user.  Confirm if correct or not.
	Write-Host " "
	Write-Host "Confirm this is the user you wish to unlock and/or reset the password for"
	Write-Host " "
	Write-Host "Name:  $($UnlockUser.DisplayName)"
	Write-Host "Title: $($UnlockUser.Title)"
	Write-Host "Dept:  $($UnlockUser.Department)"
	Write-Host "Distinguished Name: $($UnlockUser.distinguishedName)"
	Write-Host " "
	Write-Host "Lock Status: $($UnlockUser.LockedOut)"
	Write-Host " "
	Write-Warning "Is this the account you wish to modify? Please confirm."
	Write-Host " "
	$script:Confirm = Read-Host "Y or N"
}

#Function to Unlock the account only.  No password reset performed.
function Unlock-Function
{
UserInfo
if($confirm -eq "Y"){
	Unlock-ADAccount -Identity $UnlockUser.SamAccountName
    Write-Host " "
	Write-Host "Account unlocked"
    Write-Host " "
	Pause
	Menu
	}
Elseif ($Confirm -ne "y"){
	Write-Warning "No changes being made because you did not confirm the request."
	Pause
	Menu
	}
}

#Function to unlock and reset the users password to the default set above in $NewPass.
function UnlockReset-Function
{
UserInfo
if($Confirm -eq "Y"){
	Unlock-ADAccount -Identity $UnlockUser.SamAccountName
	Set-ADAccountPassword -identity $UnlockUser.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPass -Force)
	Set-aduser -Identity $UnlockUser.SamAccountName -changepasswordatlogon $True
    Write-Host " "
    Write-Host "User account unlocked and password reset."
    Write-Host " "
    Write-Host "The new password is $($NewPass)"
    Write-Host " "
    Pause
    Menu
	}
Elseif ($Confirm -ne "Y"){
	Write-Warning "No changes being made because you did not confirm the request."
	Pause
	Menu
	}
}

#Main menu for script.  Call functions determined by menu selection.
Function Menu
{
do{
Clear
Write-Host "#####################################"
Write-Host "#                                   #"
Write-Host "#       Account Reset Tool          #"
Write-Host "#                                   #"
Write-Host "#####################################"
Write-Host " "
Write-Host "Menu Options:"
Write-Host " "
#Menu options.  Unlock, or unlock & reset.
[int]$xMenuChoiceA = 0
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 99 ){
Write-Host "Choose an option:" -BackgroundColor DarkGreen
Write-host "1. Unlock Only"
Write-host "2. Unlock & Reset Password"
Write-Host "99. Exit"

[Int]$xMenuChoiceA = read-host "Please enter an option 1 to 99..." }
Switch( $xMenuChoiceA ){
  1{$RunScript = Unlock-Function}
  2{$RunScript = UnlockReset-Function}
  99{$RunScript = Exit}
  }
$RunScript
}
while ($RunScript -ne "99")
}

#Execute menu to start script.
Menu