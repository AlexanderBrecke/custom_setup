param($packages, $silent)

# --- FUNCTIONS ---

function installWinget{
    $progressPreference = 'silentlyContinue'

    # Bundle download info
    $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    Write-Information "Downloading winget..."
    # Get bundles
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    # Install bundles
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage $latestWingetMsixBundle
    # Remove bundles
    Remove-Item "./$latestWingetMsixBundle"
    Remove-Item "Microsoft.VCLibs.x64.14.00.Desktop.appx"
}

function isInstalled($p1){
    winget list -q $p1 | Out-Null;
    return $?;
}

function addToReport($name, $id, $didInstall){
    $script:report += [psobject]@{
        name = $name
        id = $id
        didInstall = $didInstall
    }
}

# --- ---

# --- LOGIC --- 

$report = @();

#Make sure winget exist
# Needed for installing packages
if(-Not (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe)) {
    installWinget;
    addToReport "winget" "" $true
} else {
    addToReport "winget" "" $false
}

# Make sure terminal is installed
if(!(isInstalled "Microsoft.WindowsTerminal")){
    winget install Microsoft.WindowsTerminal --silent
    addToReport "terminal" "Microsoft.WindowsTerminal" $true
} else {
    addToReport "terminal" "Microsoft.WindowsTerminal" $false
}


# Install all provided packages
for($i=0; $i -lt $packages.Length; $i++){
    Write-Host "Checking: $($packages[$i].packageName)"
    if(!(isInstalled $packages[$i].wingetInfo.id)){
        Write-Host installing $packages[$i].packageName
        if($silent){
            winget install --id $packages[$i].wingetInfo.id --silent
        } else {
            winget install --id $packages[$i].wingetInfo.id
        }
        addToReport $packages[$i].packageName $packages[$i].wingetInfo.id $true
    } else {
        Write-Host $packages[$i].packageName already installed, skipping..
        addToReport $packages[$i].packageName $packages[$i].wingetInfo.id $false
    }
}


return $report


# --- ---
