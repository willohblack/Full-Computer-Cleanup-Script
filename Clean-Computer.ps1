# Clean-Computer.ps1
# Fully silent: empties Downloads, empties Recycle Bin, closes browsers,
# clears history/cookies/passwords/sessions/cache. Irreversible.

# 1. Close major browsers
$browsers = @("chrome", "msedge", "firefox", "brave", "opera", "opera_gx")
foreach ($proc in $browsers) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# 2. Empty Downloads folder
$downloads = Join-Path $env:USERPROFILE "Downloads"
if (Test-Path $downloads) {
    Get-ChildItem -Path $downloads -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Empty Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# 4. Clear browser data
function Clear-ChromiumData {
    param([string]$UserDataPath)
    if (-not (Test-Path $UserDataPath)) { return }

    $profiles = Get-ChildItem -Path $UserDataPath -Directory -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -eq "Default" -or $_.Name -like "Profile *"
    }

    foreach ($profile in $profiles) {
        $p = $profile.FullName
        $itemsToDelete = @(
            "History", "History-journal", "Visited Links",
            "Cookies", "Cookies-journal", "Network\Cookies", "Network\Cookies-journal",
            "Login Data", "Login Data-journal", "Login Data For Account",
            "Web Data", "Web Data-journal",
            "Sessions", "Session Storage", "Local Storage", "IndexedDB",
            "Service Worker", "Cache", "Code Cache", "GPUCache", "ShaderCache",
            "Media Cache", "File System", "blob_storage",
            "Top Sites", "Shortcuts", "Favicons", "Network Action Predictor"
        )
        foreach ($item in $itemsToDelete) {
            $full = Join-Path $p $item
            if (Test-Path $full) {
                Remove-Item $full -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    Remove-Item (Join-Path $UserDataPath "ShaderCache") -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $UserDataPath "GrShaderCache") -Recurse -Force -ErrorAction SilentlyContinue
}

# Chrome
Clear-ChromiumData "$env:LOCALAPPDATA\Google\Chrome\User Data"

# Edge
Clear-ChromiumData "$env:LOCALAPPDATA\Microsoft\Edge\User Data"

# Brave
Clear-ChromiumData "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"

# Opera / Opera GX
Clear-ChromiumData "$env:APPDATA\Opera Software\Opera Stable"
Clear-ChromiumData "$env:APPDATA\Opera Software\Opera GX Stable"

# Firefox
$ffProfiles = @(
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles",
    "$env:APPDATA\Mozilla\Firefox\Profiles"
)
foreach ($base in $ffProfiles) {
    if (Test-Path $base) {
        Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $p = $_.FullName
            $ffItems = @(
                "places.sqlite", "places.sqlite-shm", "places.sqlite-wal",
                "cookies.sqlite", "cookies.sqlite-shm", "cookies.sqlite-wal",
                "logins.json", "key4.db", "key3.db",
                "formhistory.sqlite", "permissions.sqlite",
                "sessionstore.jsonlz4", "sessionstore-backups",
                "cache2", "startupCache", "thumbnails", "storage"
            )
            foreach ($item in $ffItems) {
                $full = Join-Path $p $item
                if (Test-Path $full) {
                    Remove-Item $full -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}