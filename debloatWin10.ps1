<#
Name: Windows 10 Debloated
Author: Clark Crisp & George Babichev
Created: 5/15/2019
Updated: 5/19/2019
Tested: Windows 10, 1809 Professional

Version: 1.1

This script removes unnecessary built-in Apps
& makes some quality of life changes in the registry

HOW TO USE: After setting up Windows 10, run this script 
BEFORE a domain join

Output colors
- Red: Error
- Green: Success
- Yellow: Info

#>

$ProgressPreference=’SilentlyContinue’ # Removes the default PowerShell progress window

# Enable Logging
$LogPath = "C:\Scripts\Logging"
$LogName = $LogPath + "\Log.txt"

if (!(Test-Path $LogName)) { 
    #If the $logName does not exist, create it
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    New-Item -Path $LogName -ItemType File -Force | Out-Null
}
#Easy to read name of removeable Apps
$RemoveableApps = @(
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.GetStarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MSPaint"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.ScreenSketch"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.Windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

$RemoveableFolders = @(
    "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" # Music
    "{088e3905-0323-4b02-9826-5d99428e115f}" # Downloads
    "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" # Pictures
    "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" # Videos
    "{d3162b92-9365-467a-956b-92703aca08af}" # Documents
    "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" # Desktop
    "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" # 3D Objects
)

Function WriteToLog {
#Writes to log
    param($Message, $color)

    $pre = ""

    if ($color -eq "red"){
        $pre = "ERROR: "
    }
    if ($color -eq "green"){
        $pre = "SUCCESS: "
    }
    if ($color -eq "yellow"){
        $pre = "INFO: "
    }
    if (!$color) {
        $color = "white"
        $pre = "ACTION: "
    }

    $currentDate = Get-Date
    Add-Content -Path $LogName -Value "$pre $currentDate - $Message"
    Write-Host "$pre $currentDate - $Message" -ForegroundColor $color
}

Function ModifyReg {
    param($Path, $key, $keyVal, $action, $type)

    <#
        Modifies the registry
        $path = psdrive path
        $key = name of registy KEY or attribute
        $keyVal = value of attribute
        $type = Type of attribute (dword, string, etc)
        $action = 
            add - Adds an attribute to a key
            create -  Creates a key
            deleteK - delets a key
            deleteA - delets an attribute
    #>

    if ($action -eq "add"){
    # Adds a value to a Key
        try {
            if (Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)
            {
                # A value already exists, let's modify it
                Set-ItemProperty -Path $path -Name $key -Value $keyVal
            }
            else {
                New-ItemProperty $Path -Name $key -Value $keyVal -PropertyType $type -ErrorAction Stop | Out-Null
            }
        }Catch {
            WriteToLog -Message "Error 0x000221" -color "red"
        }
    }
    if ($action -eq "create"){
    # Creates a key
        $fullPath = $path + $key

        if (Get-Item $fullPath -ErrorAction SilentlyContinue){}
        Else{
            # If this location doesn't exist in the registry, create it
            try {
                New-Item $Path -Name $key -ErrorAction Stop | Out-Null
                WriteToLog -Message "$fullPath created" -color "green"
            } Catch {
                WriteToLog -Message "Error 0x000222" -color "red"
            }        
        
        }
    }
    if ($action -eq "deleteK"){
    # Deletes a Key
        if (Get-Item -Path $path -ErrorAction SilentlyContinue){
        # If item exists, remove it
            Remove-Item -Path $Path -Recurse 
            WriteToLog -Message "Removed $path" -color "green"
        }
        Else{
            WriteToLog -Message "$path has already been removed" -color "yellow"
        }
            

    }
    if ($action -eq "deleteA"){
    # Deletes an attribute
        if (Get-ItemProperty -Path $Path -Name $key -ErrorAction SilentlyContinue){
            try {
                Remove-ItemProperty -Path $Path -Name $key -ErrorAction Stop | Out-Null
            } Catch {
                WriteToLog -Message "Error 0x000223" -color "red"
            }
        }
    }
}

Function Remove-TheBloat-CU {
# Removes the bloat for the current user
    WriteToLog -Message "Starting current user bloat removal"
    ForEach ($bloat in $RemoveableApps) { 
        Try {
            $CurrentPackage = Get-AppxPackage -Name $Bloat

                If ($CurrentPackage) {
                    $ThePackageName = $CurrentPackage.PackageFullName 
                    #Point of failure line, If fails go to line 62
                    Remove-AppxPackage -Package $ThePackageName -ErrorAction Stop
                    WriteToLog -Message "Successfully Removed $bloat" -color "green"
                } Else {
                    WriteToLog -Message "$Bloat already removed!" -color "yellow"
            }
        } Catch { 
            WriteToLog -Message "Error removing $bloat" -color "red"
        }
    }
    WriteToLog -Message "Completed current user bloat removal"
}

Function Remove-TheBloat-AU {
# Removes the bloat for all (new) users
    WriteToLog -Message "Starting all user bloat removal"
    ForEach ($bloat in $RemoveableApps) { 
        Try {
            $CurrentPackage = Get-AppxProvisionedPackage -online | Where-Object -Property DisplayName -eq $bloat
                If ($CurrentPackage) {
                    $ThePackageName = $CurrentPackage.PackageName 
                    Remove-AppxProvisionedPackage -online -Package $ThePackageName -ErrorAction Stop | Out-Null
                    WriteToLog -Message "Successfully Removed AllUser $bloat" -color "green"
                } Else {
                    WriteToLog -Message "$Bloat already removed" -color "yellow"
            }
        } Catch { 
            WriteToLog -Message "Was not able to remove $bloat" -color "red"
        }
    }
    WriteToLog -Message "Completed all user bloat removal"
}

Function Replace-StartMenu {
# Downloads the latest cleaned startMenu layout file & applies

    $url = "http://tools.xantrion.com/DefaultLayouts.xml"
    $Destination = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell"
    $DestinationFileName = $Destination + "\DefaultLayouts.xml"

    # Deletes current start menu layout file
    try{
        get-ChildItem -Path $Destination | Remove-Item -Force -ErrorAction Stop
        WriteToLog -Message "Removed Original StartMenuLayout file" -color "green"
    } Catch {
        WriteToLog -Message "Error deleting original StartMenuLayout File" -color "red"
		WriteToLog -Message "Skipping download & install of new file" -color "red"
    }
    
    While (!(Test-Path $DestinationFileName)) {
        try {
            WriteToLog -Message "downloading new StartMenuLayout File"
            Start-BitsTransfer -Source $Url -Destination $Destination
            WriteToLog -Message "New StartMenuLayout file installed" -color "green"
        }Catch {
            WriteToLog -Message "Error downloading & installing new StartMenuLayouts file" -color "red"
        }    
    }
}

Function Customize-Windows {

    WriteToLog -Message "Loading ntuser registry hive"
    # Loads default new user HKCU hive
    reg load "HKLM\MAZY"  C:\users\default\NTUSER.DAT | Out-Null
        
    # Sets Explorer to launch to "This PC" by default instead of  "Quick Access"
    ModifyReg -Path "HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "LaunchTo" -keyVal "1" -type "dword"-action "add" 
    # Hides search box
    ModifyReg -Path "HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\search\" -key "SearchboxTaskbarMode" -keyVal "0" -type "dword" -action "add"
    # Hides people button part 1
    ModifyReg -Path "HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -key "People" -action "create"
    # Hides people button part 2
    ModifyReg -Path "HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -key "PeopleBand" -keyVal "0" -type "dword" -action "add"
    # Disables OneDrive from installing on Launch
    ModifyReg -Path "HKLM:\MAZY\Software\Microsoft\Windows\CurrentVersion\Run" -key "OneDriveSetup" -action "deleteA"
    


    WriteToLog -Message "Unmounting registry hive"
    # Garbage Collection to cleanup any open handles on registry hive
    [gc]::Collect()
    reg unload HKLM\MAZY | Out-Null
    WriteToLog -Message "Unloaded registry hive"
}

Function RemoveExplorerFolders {

    WriteToLog -Message "Starting Explorer cleanup"

	$RegistryPath64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
	$RegistryPath32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"

    <#
        Why have both registry paths? 
        Because, what if you're running a 32 bit OS? But more importantly
        If you are running some legacy win32 app, and click a button to "browse for files" 
        The bloatware shows up!
    #>

	ForEach ($crap in $RemoveableFolders) {
		Set-Location $RegistryPath64
		try {
			Remove-Item -Path "$crap" -ErrorAction Stop | Out-Null
			WriteToLog -Message "Successfully removed registry item $crap" -color "green"
		} Catch {
			WriteToLog -Message "$crap has already been removed for the 64bit" -color "yellow"
		}
		Set-Location $RegistryPath32
		try {
			Remove-Item -Path "$crap" -ErrorAction Stop | Out-Null
			WriteToLog -Message "Successfully removed registry item $crap" -color "green"
		} Catch {
			WriteToLog -Message "$crap has already been removed for the 32bit" -color "yellow"
		}
	}

    WriteToLog -Message "Completed Explorer cleanup"

}

Function ApplyMiscRegEdits{

    WriteToLog -Message "Starting Context Menu Cleanup"

    $Extensions = @(
        ".3mf"
        ".bmp"
        ".fbx"
        ".gif"
        ".glb"
        ".jfif"
        ".jpe"
        ".jpeg"
        ".jpg"
        ".obj"
        ".ply"
        ".png"
        ".stl"
        ".tif"
        ".tiff"
    )
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    # Removes "Open with 3D Print & 3D Edit" context menu on file types below:
    ForEach ($ext in $Extensions){
        ModifyReg -Path "HKCR:\SystemFileAssociations\$ext\Shell\3D Edit" -action "deleteK"
        ModifyReg -Path "HKCR:\SystemFileAssociations\$ext\Shell\3D Print" -action "deleteK"
    }

    Remove-PSDrive -Name HKCR

    WriteToLog -Message "Completed Context Menu Cleanup"
}

# Check for admin rights, quit if not admin
If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	WriteToLog -Message "Please run as administrator." -color "red"
	Read-Host
	Exit
}



Remove-TheBloat-CU
Remove-TheBloat-AU
Replace-StartMenu
Customize-Windows
RemoveExplorerFolders
ApplyMiscRegEdits

WriteToLog -Message "Bloatware removale completed! -- Press Enter to quit."
Read-Host
