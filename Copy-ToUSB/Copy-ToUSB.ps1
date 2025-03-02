param (
    # Drive index to use (will prompt if not provided)
    [Parameter()]
    [int]$DriveIndex = 0,
    
    # Paths to copy (comma-separated if provided as a string)
    [Parameter()]
    [string[]]$Paths,
    
    # Format the drive before copying
    [Parameter()]
    [switch]$Format,
    
    # Overwrite existing files
    [Parameter()]
    [switch]$Overwrite,
    
    # Maximum size of USB drives to detect (in GB)
    [Parameter()]
    [int]$MaxSizeGB = 32
)

# Set Execution Policy for the Session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 1. Find USB Drives (<= MaxSizeGB)
Write-Host "Finding USB drives..."
$usbDrives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=2" | 
             Where-Object { ($_.Size / 1GB) -le $MaxSizeGB }

if (-not $usbDrives) {
    Write-Host "No suitable USB drives found."
    exit
}

# 2. Display and User Selects Drive (if not provided via parameter)
Write-Host "Available USB drives:"
for ($i = 0; $i -lt @($usbDrives).Count; $i++) {
    $drive = $usbDrives[$i]
    $sizeGB = [math]::Round($drive.Size / 1GB, 1)
    Write-Host "$($i + 1). $($drive.DeviceID) ($($drive.VolumeName)) - $sizeGB GB"
}

$index = $DriveIndex - 1
if ($index -lt 0 -or $index -ge @($usbDrives).Count) {
    # Invalid or no index provided, prompt user
    $selectedDriveIndex = Read-Host "Enter the number of the drive you want to use"
    $index = [int]$selectedDriveIndex - 1
    
    if ($index -lt 0 -or $index -ge @($usbDrives).Count) {
        Write-Host "Invalid drive number."
        exit
    }
}

$selectedDrive = $usbDrives[$index]
$driveLetter = $selectedDrive.DeviceID
Write-Host "Selected drive: $driveLetter ($($selectedDrive.VolumeName))"

# 3. Get Files/Folders to Copy (if not provided via parameter)
if (-not $Paths -or $Paths.Count -eq 0) {
    Write-Host "Enter the paths of the files or folders to copy (separated by commas):"
    $pathInput = Read-Host
    
    # Handle both array input and comma-separated string
    if ($pathInput -is [string]) {
        $Paths = $pathInput -split "," | ForEach-Object { $_.Trim() }
    } else {
        $Paths = $pathInput
    }
}

# 4. Check USB Drive and Handle Overwrites/Formatting
$driveContents = Get-ChildItem $driveLetter -ErrorAction SilentlyContinue

if ($driveContents -and -not $Format -and -not $Overwrite) {
    $formatChoice = Read-Host "USB drive is not empty. Do you want to format it? (Y/N)"
    if ($formatChoice -eq "Y") {
        $Format = $true
    } else {
        $overwriteChoice = Read-Host "Do you want to overwrite existing files? (Y/N)"
        $Overwrite = $overwriteChoice -eq "Y"
    }
}

if ($Format) {
    Write-Host "WARNING: Formatting will erase all data on the drive."
    $confirm = Read-Host "Type 'YES' to confirm formatting"
    
    if ($confirm -eq "YES") {
        Format-Volume -DriveLetter $driveLetter[0] -FileSystem FAT32
        Write-Host "Drive $driveLetter has been formatted."
        $Overwrite = $true
    } else {
        Write-Host "Formatting cancelled."
        if (-not $Overwrite) {
            $overwriteChoice = Read-Host "Do you want to overwrite existing files? (Y/N)"
            $Overwrite = $overwriteChoice -eq "Y"
        }
    }
}

# 5. Copy Files/Folders
foreach ($item in $Paths) {
    if (Test-Path $item) {
        try {
            if (Test-Path -Path $item -PathType Container) {
                # Folder
                Copy-Item -Path $item -Destination $driveLetter -Recurse -Force:$Overwrite -ErrorAction Stop
                Write-Host "Folder '$item' copied successfully."
            } else {
                # File
                Copy-Item -Path $item -Destination $driveLetter -Force:$Overwrite -ErrorAction Stop
                Write-Host "File '$item' copied successfully."
            }
        } catch {
            Write-Error $_
            Write-Host "Error copying '$item'."
        }
    } else {
        Write-Host "Path '$item' not found."
    }
}

Write-Host "Copy process complete."