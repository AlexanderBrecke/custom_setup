function isConfigured {
    if(Test-Path "../../.configured"){
        $configFile = (Get-Content "../../.configured" -Raw) | ConvertFrom-Json
        foreach($property in $configFile.configurations){
            if($property.platform -eq "windows"){
                Write-Output $property
                return $true
            }
        }
        return $false
    }
    return $false
}

# Check for configured file
# If windows is configured exit
if(isConfigured){
    Write-Host Windows already configured, exiting..
    exit
} else {
    $configured = @{
        configurations = @(
            @{
                platform = "windows"
                packages = @()
                terminalProfile = @()
            }
        )
    }
}

# Check if config file exist
# If not use config_example.json
if(Test-Path "../../config.json"){
    $config = (Get-Content "../../config.json" -Raw) | ConvertFrom-Json
} else {
    $config = (Get-Content "../../config_example.json" -Raw) | ConvertFrom-Json
}

# Go to installer location
# Start the installer, give it list of packages
# and if it should install silently or not
Push-Location ../../installer
$packageInfo = ./installer.ps1 $config.packageManagement.packages $config.packageManagement.silentInstall
$index = [array]::IndexOf($configured.configurations.platform, "windows")
$configured.configurations[$index].packages += $packageInfo
Pop-Location



$terminalInfo = ./terminal_config.ps1 $config.terminalProfileSettings
$configured.configurations[$index].terminalProfile += $terminalInfo

# Write a .configured file to the setup folder
Write-Output $configured | ConvertTo-Json -Depth 4 | Out-File "..\..\.configured" -Encoding utf8

exit;
