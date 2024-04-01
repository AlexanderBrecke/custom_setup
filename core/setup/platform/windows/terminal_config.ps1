param($terminalConfig)

#---------------------------
function getSettingsPath{
    # Possible paths for terminal settings with normal install
    $settingsPath1 = "~\AppData\Local\Microsoft\Windows Terminal\settings.json"
    $settingsPath2 = "~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    # Determine which is correct
    if(Test-Path $settingsPath1){
        return $settingsPath1
    }
    if(Test-Path $settingsPath2){
        return $settingsPath2
    }
    return $false
}
#---------------

$report = @()

Write-Host Setting up terminal settings..

# Make sure there is a fragment folder
$fragmentFolder = "C:\ProgramData\Microsoft\Windows Terminal\Fragments\custom_handler"
if(-Not (Test-Path $fragmentFolder)){
    Write-Host "Creating fragment path: '$fragmentFolder'"
    mkdir $fragmentFolder
}

# Get path to terminal settings
$pathToSettings = getSettingsPath

# If no path was found, return error
if($pathToSettings -eq $false){
    Write-Host Could not find path to terminal settings.. Exiting..
    $report += @{
        Error = @{
            location = "terminal_config.ps1"
            Error = "Could not find terminal settings"
        }
    }
    return $report
}

# Get settings file
$settings = (Get-Content $pathToSettings -Raw) | ConvertFrom-Json

# Create terminal profiles
$terminalProfile = $terminalConfig.windowsProfile
for($i=0; $i -lt $terminalProfile.profiles.Length; $i++){
    if($terminalProfile.profiles[$i].createOrUpdate -eq "create"){
        if(-Not (Test-Path "$fragmentsFolder\$($terminalProfile.profiles[$i].name).json")){
            # Fragment does not exist, create one
            Write-Host Creating profile fragment..
            $guid = [guid]::NewGuid();
            $terminalProfile.profiles[$i] | Add-Member -Name "guid" -Value "{$guid}" -MemberType NoteProperty
            $terminalProfile.profiles[$i].PSObject.Properties.Remove('createOrUpdate')

            # Adding custom tools or not
            $didAddCustomTools = $false
            if($terminalConfig.addCustomTools){
                $corefolder = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
                $terminalTools = "$corefolder\terminal_tools\windows\setup.bat"
                $terminalProfile.profiles[$i].commandLine = "$($terminalProfile.profiles[$i].commandline) /K call $terminalTools"
                $didAddCustomTools = $true
            }

            # Fill out report for .configured file
            $report += [psobject]@{
                fragmentLocation = "$fragmentFolder/$($terminalProfile.profiles[$i].name).json"
                defaultProfile = $terminalProfile.profiles[$i].makeDefault
                addedCustomTools = $didAddCustomTools
                startingDirectory = $terminalProfile.profiles[$i].startingDirectory
                id = "{$guid}"
            }
            
            # If we should, update terminal settings with created profile as default
            if($terminalProfile.profiles[$i].makeDefault){
                $settings.defaultProfile = "{$guid}"
            }

            $terminalProfile.profiles[$i].PSObject.Properties.Remove('makeDefault')

            # Write the terminal profile to the fragment folder
            Write-Output $terminalProfile | ConvertTo-Json |Out-File "$fragmentFolder/$($terminalProfile.profiles[$i].name).json" -Encoding utf8
        }
    }
}

# Write changes to the settings file
Write-Output $settings | ConvertTo-Json -Depth 32 | Out-File "$pathToSettings" -Encoding utf8

return $report
