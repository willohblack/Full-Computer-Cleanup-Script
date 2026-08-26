# Clean-Computer-System.ps1
# Optimized for running as SYSTEM (Faronics Deploy / Deep Freeze Custom Script)
# Cleans Downloads, Recycle Bin, and browser data for ALL user profiles

# Close major browsers
$browsers = @("chrome", "msedge", "firefox", "brave", "opera", "opera_gx")
foreach ($proc in $browsers) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# Empty Recycle Bin (works for all users when run as SYSTEM)
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Get all real user profiles
$userProfiles = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -notin @("Public", "Default", "Default User", "All Users") }

foreach ($user in $userProfiles) {
    $userPath = $user.FullName

    # 1. Empty Downloads
    $downloads = Join-Path $userPath "Downloads"
    if (Test-Path $downloads) {
        Get-ChildItem -Path $downloads -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 2. Clear Chromium-based browsers
    function Clear-ChromiumData {
        param([string]$UserDataPath)
        if (-not (Test-Path $UserDataPath)) { return }

        $profiles = Get-ChildItem -Path $UserDataPath -Directory -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -eq "Default" -or $_.Name -like "Profile *" }

        foreach ($profile in $profiles) {
            $p = $profile.FullName
            $items = @(
                "History", "History-journal", "Visited Links",
                "Cookies", "Cookies-journal", "Network\Cookies", "Network\Cookies-journal",
                "Login Data", "Login Data-journal", "Login Data For Account",
                "Web Data", "Web Data-journal",
                "Sessions", "Session Storage", "Local Storage", "IndexedDB",
                "Service Worker", "Cache", "Code Cache", "GPUCache", "ShaderCache",
                "Media Cache", "File System", "blob_storage",
                "Top Sites", "Shortcuts", "Favicons", "Network Action Predictor"
            )
            foreach ($item in $items) {
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
    Clear-ChromiumData (Join-Path $userPath "AppData\Local\Google\Chrome\User Data")

    # Edge
    Clear-ChromiumData (Join-Path $userPath "AppData\Local\Microsoft\Edge\User Data")

    # Brave
    Clear-ChromiumData (Join-Path $userPath "AppData\Local\BraveSoftware\Brave-Browser\User Data")

    # Opera / Opera GX
    Clear-ChromiumData (Join-Path $userPath "AppData\Roaming\Opera Software\Opera Stable")
    Clear-ChromiumData (Join-Path $userPath "AppData\Roaming\Opera Software\Opera GX Stable")

    # Firefox
    $ffBases = @(
        (Join-Path $userPath "AppData\Local\Mozilla\Firefox\Profiles"),
        (Join-Path $userPath "AppData\Roaming\Mozilla\Firefox\Profiles")
    )
    foreach ($base in $ffBases) {
        if (Test-Path $base) {
            Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $p = $_.FullName
                $items = @(
                    "places.sqlite", "places.sqlite-shm", "places.sqlite-wal",
                    "cookies.sqlite", "cookies.sqlite-shm", "cookies.sqlite-wal",
                    "logins.json", "key4.db", "key3.db",
                    "formhistory.sqlite", "permissions.sqlite",
                    "sessionstore.jsonlz4", "sessionstore-backups",
                    "cache2", "startupCache", "thumbnails", "storage"
                )
                foreach ($item in $items) {
                    $full = Join-Path $p $item
                    if (Test-Path $full) {
                        Remove-Item $full -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }
}
