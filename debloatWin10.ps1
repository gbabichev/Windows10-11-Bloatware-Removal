<#
Name: Windows 10 Debloated
Author: Clark Crisp & George Babichev
Created: 5/15/2019
Updated: 7/26/2019
Tested: Windows 10, 1809, 1903 Professional

Version: 1.3.1

This script removes unnecessary built-in Apps
& makes some quality of life changes in the registry

HOW TO USE: After setting up Windows 10, run this script 
BEFORE a domain join

Output colors
- Red: Error
- Green: Success
- Yellow: Info


#>

$ProgressPreference='SilentlyContinue' # Removes the default PowerShell progress window

# Enable Logging
$LogPath = "C:\Scripts\Logging"
$LogName = $LogPath + "\DebloatLog.txt"

if (!(Test-Path $LogName)) { 
    #If the $logName does not exist, create it
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    New-Item -Path $LogName -ItemType File -Force | Out-Null
}
#Easy to read name of removeable Apps
$RemoveableApps = @(
	"4DF9E0F8.Netflix" # From Dell 1903 Image
	"C27EB4BA.DropboxOEM" # From Dell 1903 Image
	"DellInc.DellCustomerConnect" # From Dell 1903 Image
	"DellInc.DellDigitalDelivery" # From Dell 1903 Image
	"DellInc.DellPowerManager" # From Dell 1903 Image
	"DellInc.DellSupportAssistforPCs" # From Dell 1903 Image
	"DellInc.MyDell" # From Dell 1903 Image
	"ScreenovateTechnologies.DellMobileConnect" # From Dell 1903 Image
	"STMicroelectronicsMEMS.DellFreeFallDataProtection" # From Dell 1903 Image
    "7EE7776C.LinkedInforWindows" # From Dell 1803 Image
    "DellInc.DellDigitalDelivery" # From Dell 1803 Image
    "DellInc.DellSupportAssistforPCs" # From Dell 1803 Image
    "Microsoft.RemoteDesktop" # From Dell 1803 Image
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


Function WriteToLog {
#Writes to logfile
    param($Message, $color)

    $pre = "" #Variable for appending Error/Success/Info to the start of each line

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
# Although this step isn't necessarily important, it is required if you sysprep
    WriteToLog -Message "Starting current user bloat removal"
    ForEach ($bloat in $RemoveableApps) { 
        Try {
            $CurrentPackage = Get-AppxPackage -Name $Bloat

                If ($CurrentPackage) {
                    $ThePackageName = $CurrentPackage.PackageFullName 
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
# Creates a cleaned Start Menu layout file 

$Layouts = '<?xml version="1.0" encoding="utf-8"?>
<FullDefaultLayoutTemplate 
    xmlns="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    Version="1">
    <StartLayoutCollection>
        <!-- 6 cell wide Desktop layout with Preinstalled apps and no skype -->
        <!-- 6 cell wide Desktop layout with Preinstalled apps -->
        
      
        <!-- 8 cell wide Desktop layout with Preinstalled apps and no skype -->

        <!-- 8 cell wide Desktop layout with Preinstalled apps -->
        

        <!-- 6 cell wide Cloud layout with Preinstalled apps and no skype -->
        
        <!-- 6 cell wide Cloud layout with Preinstalled apps -->
        <StartLayout
            GroupCellWidth="6"
            PreInstalledAppsEnabled="false">
        <start:Group Name="Windows">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" />
        </start:Group>
        </StartLayout>
        <!-- N-SKU 6 cell wide Cloud layout -->

        <!-- N-SKU 6 cell wide Desktop layout -->

        <!-- N-SKU 8 cell wide Desktop layout -->

        <!-- 6 cell wide Desktop layout with No Preinstalled apps and no skype -->

        <!-- 6 cell wide Desktop layout with No Preinstalled apps -->
        <StartLayout
            GroupCellWidth="6"
            PreInstalledAppsEnabled="false">
        <start:Group Name="Windows">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" />
        </start:Group>
        </StartLayout>

        <!-- 8 cell wide Desktop layout with No Preinstalled apps and no skype -->

        <!-- 8 cell wide Desktop layout with No Preinstalled apps -->

        <!-- Long Term Servicing Branch 6 cell -->
        <StartLayout
            GroupCellWidth="6"
            SKU="LongTermServicingBranch">
        <start:Group Name="Windows">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" />
        </start:Group>
        </StartLayout>

        <!-- Long Term Servicing Branch 8 cell -->

        <!-- PPI 8 cell wide -->

        <!-- Server 6 cell wide -->
        
        <!-- Server 8 cell wide -->
       

    </StartLayoutCollection>
</FullDefaultLayoutTemplate>'

    $Destination = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml"
    $LayoutMod = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
    if (Test-Path $LayoutMod){
    # Some OEM's include a modification to the defualt layout to add OEM bloat. Nuke that too.
        try {
            Remove-Item -Path $LayoutMod -Force -ErrorAction Stop
            WriteToLog -Message "Removed LayoutModification" -color "green"
        } Catch {
            WriteToLog -Message "Could not remove LayoutModification" -color "red"
        }
    }
    if (!(Test-Path $Destination)) {
    # First we check if the file exists, and if it does we delete it.
    # If for some reason the DefaultLayouts file doesn't exist, write a message to the log and
    # Attempt to create it
        WriteToLog -Message "DefaultLayouts file does not exist.. Attempting to create" -color "yellow"
    }
    else {
    # File exists, let's try to delete it
        try{
            Remove-Item -Path $Destination -Force -ErrorAction Stop
            WriteToLog -Message "Removed Original StartMenuLayout file" -color "green"
        } Catch {
            WriteToLog -Message "Error deleting original StartMenuLayout File" -color "red"
        }
    }

    if (!(Test-Path $Destination)) {
    # Creates new file from XML above
        try {
            New-Item -Path $Destination -ItemType File -ErrorAction Stop | Out-Null
            Set-Content -Path $Destination $Layouts -ErrorAction Stop | Out-Null
            WriteToLog -Message "New StartMenuLayout file installed" -color "green"
        }Catch {
            WriteToLog -Message "Error installing new StartMenuLayouts file" -color "red"
        }  
    }
}

Function Customize-Windows {
# Sets settings for all new users. See below comments for detail.

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

<#
    This function removes "3D Objects, Desktop, Documents, Downloads, Pictures, Videos" 
    From the "This PC" view in Explorer, and from the "This PC" side bar in Explorer
#>

    WriteToLog -Message "Starting Explorer cleanup"

	$RegistryPath64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
	$RegistryPath32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
    $RemoveableFolders = @(
        "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" # Music
        "{088e3905-0323-4b02-9826-5d99428e115f}" # Downloads
        "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" # Pictures
        "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" # Videos
        "{d3162b92-9365-467a-956b-92703aca08af}" # Documents
        "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" # Desktop
        "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" # 3D Objects
    )
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

<#
    Removes "Open with 3D Print" on extensions listed below.
    Disables CloudContent 
#>

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

WriteToLog -Message "Bloatware removale completed!"
#Read-Host
