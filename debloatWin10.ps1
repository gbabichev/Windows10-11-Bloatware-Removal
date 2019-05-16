<#
Name: Windows 10 Debloated
Author: Clark Crisp & George Babichev
Created: 5/15/2019
Updated: 5/15/2019
Tested: Windows 10, 1809 Professional

This script removes unnecessary built-in Apps
& makes some quality of life changes in the registry

HOW TO USE: After setting up Windows 10, run this script 
BEFORE a domain join

TODO: Remove Task Scheduler bloat


#>

#Enable Logging
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

Function WriteToLog {
#Writes to log
    param($Message, $color)

    if (!$color){
        $color = "white"
    }

    $currentDate = Get-Date
    Add-Content -Path $LogName -Value "$currentDate - $Message"
    Write-Host "$currentDate - $Message" -ForegroundColor $color
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
                    WriteToLog -Message "Successfully Removed $ThePackageName"
                } Else {
                    WriteToLog -Message "$Bloat does not exist" -color "red"
            }
        } Catch { 
            WriteToLog -Message "Was not able to remove $bloat" -color "red"
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
                    #Point of failure line, If fails go to line 62
                    Remove-AppxProvisionedPackage -online -Package $ThePackageName -ErrorAction Stop | Out-Null
                    WriteToLog -Message "Successfully Removed AllUser $bloat"
                } Else {
                    WriteToLog -Message "$Bloat does not exist" -color "red"
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
        get-ChildItem -Path $Destination | Remove-Item -Force
        WriteToLog -Message "Removed Original StartMenuLayout file"
    } Catch {
        WriteToLog -Message "Error deleting original StartMenuLayout File" -color "red"
    }
    
    While (!(Test-Path $DestinationFileName)) {
        try {
            WriteToLog -Message "downloading new StartMenuLayout File"
            Start-BitsTransfer -Source $Url -Destination $Destination
            WriteToLog -Message "New StartMenuLayout file installed"
        }Catch {
            WriteToLog -Message "Error downloading & installing new StartMenuLayouts file" -color "red"
        }    
    }
}

Function Customize-Windows {
    Try {
        WriteToLog -Message "Loading ntuser registry hive"
        reg load "HKLM\MAZY"  C:\users\default\NTUSER.DAT | Out-Null
        
        try {
            New-ItemProperty HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Launchto -Value 1 -ErrorAction Stop | Out-Null
        } Catch {
            WriteToLog -Message "LaunchTo variable already exists" -Color "red"
        }
        try {
            New-ItemProperty HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\search\ -Name SearchboxTaskbarMode -Value 0 -ErrorAction Stop | Out-Null
        } Catch {
            WriteToLog -Message "SearchBoxTaskbarMode variable already exists" -Color "red"
        }
        try {
            New-Item HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -Name People -ErrorAction Stop | Out-Null
        } Catch {
            WriteToLog -Message "People key already exists" -Color "red"
        }
        try {
            New-ItemProperty HKLM:\MAZY\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People -Name PeopleBand -Value 0 -ErrorAction Stop | Out-Null
        } Catch {
            WriteToLog -Message "PeopleBand variable already exists" -Color "red"
        }


        WriteToLog -Message "Registry changes completed"
    }Catch {
        WriteToLog -Message "Error loading/writing Registry hive"
    }




    WriteToLog -Message "Unmounting registry hive"
    # Garbage Collection to cleanup any open handles on registry hive
    [gc]::Collect()
    reg unload HKLM\MAZY
    WriteToLog -Message "Unloaded registry hive"
}


Remove-TheBloat-CU
Remove-TheBloat-AU
Replace-StartMenu
Customize-Windows