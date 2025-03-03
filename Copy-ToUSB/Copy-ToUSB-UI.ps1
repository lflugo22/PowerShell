Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set Execution Policy for the Session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Find USB Drives (<= 32GB)
function Get-USBDrives {
    param([int]$MaxSizeGB = 32)
    
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=2" | 
    Where-Object { ($_.Size / 1GB) -le $MaxSizeGB } | 
    ForEach-Object {
        $sizeGB = [math]::Round($_.Size / 1GB, 1)
        [PSCustomObject]@{
            Drive = $_.DeviceID
            Label = $_.VolumeName
            SizeGB = $sizeGB
            DriveObject = $_
            DisplayName = "$($_.DeviceID) ($($_.VolumeName)) - $sizeGB GB"
        }
    }
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "USB File Copy Utility"
$form.Size = New-Object System.Drawing.Size(600, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Create Labels
$labelDrives = New-Object System.Windows.Forms.Label
$labelDrives.Location = New-Object System.Drawing.Point(20, 20)
$labelDrives.Size = New-Object System.Drawing.Size(200, 20)
$labelDrives.Text = "Select USB Drive:"
$form.Controls.Add($labelDrives)

# Create USB Drive ComboBox
$comboBoxDrives = New-Object System.Windows.Forms.ComboBox
$comboBoxDrives.Location = New-Object System.Drawing.Point(20, 45)
$comboBoxDrives.Size = New-Object System.Drawing.Size(450, 20)
$comboBoxDrives.DropDownStyle = "DropDownList"
$form.Controls.Add($comboBoxDrives)

# Refresh Button
$buttonRefresh = New-Object System.Windows.Forms.Button
$buttonRefresh.Location = New-Object System.Drawing.Point(480, 44)
$buttonRefresh.Size = New-Object System.Drawing.Size(80, 23)
$buttonRefresh.Text = "Refresh"
$form.Controls.Add($buttonRefresh)

# Files Label
$labelFiles = New-Object System.Windows.Forms.Label
$labelFiles.Location = New-Object System.Drawing.Point(20, 80)
$labelFiles.Size = New-Object System.Drawing.Size(200, 20)
$labelFiles.Text = "Files and Folders to Copy:"
$form.Controls.Add($labelFiles)

# Files ListBox
$listBoxFiles = New-Object System.Windows.Forms.ListBox
$listBoxFiles.Location = New-Object System.Drawing.Point(20, 105)
$listBoxFiles.Size = New-Object System.Drawing.Size(450, 150)
$form.Controls.Add($listBoxFiles)

# Add Hach Files Button
$buttonHachFiles = New-Object System.Windows.Forms.Button
$buttonHachFiles.Location = New-Object System.Drawing.Point(480, 105)
$buttonHachFiles.Size = New-Object System.Drawing.Size(80, 23)
$buttonHachFiles.Text = "Hach Files"
$form.Controls.Add($buttonHachFiles)

# Add Files Button
$buttonAddFiles = New-Object System.Windows.Forms.Button
$buttonAddFiles.Location = New-Object System.Drawing.Point(480, 140)
$buttonAddFiles.Size = New-Object System.Drawing.Size(80, 23)
$buttonAddFiles.Text = "Add Files"
$form.Controls.Add($buttonAddFiles)

# Add Folder Button
$buttonAddFolder = New-Object System.Windows.Forms.Button
$buttonAddFolder.Location = New-Object System.Drawing.Point(480, 175)
$buttonAddFolder.Size = New-Object System.Drawing.Size(80, 23)
$buttonAddFolder.Text = "Add Folder"
$form.Controls.Add($buttonAddFolder)

# Remove Button
$buttonRemove = New-Object System.Windows.Forms.Button
$buttonRemove.Location = New-Object System.Drawing.Point(480, 210)
$buttonRemove.Size = New-Object System.Drawing.Size(80, 23)
$buttonRemove.Text = "Remove"
$form.Controls.Add($buttonRemove)

# Clear Button
$buttonClear = New-Object System.Windows.Forms.Button
$buttonClear.Location = New-Object System.Drawing.Point(480, 245)
$buttonClear.Size = New-Object System.Drawing.Size(80, 23)
$buttonClear.Text = "Clear All"
$form.Controls.Add($buttonClear)

# Options Group Box
$groupOptions = New-Object System.Windows.Forms.GroupBox
$groupOptions.Location = New-Object System.Drawing.Point(20, 280)
$groupOptions.Size = New-Object System.Drawing.Size(540, 60)
$groupOptions.Text = "Options"
$form.Controls.Add($groupOptions)

# Max Size Label
$labelMaxSize = New-Object System.Windows.Forms.Label
$labelMaxSize.Location = New-Object System.Drawing.Point(20, 25)
$labelMaxSize.Size = New-Object System.Drawing.Size(150, 20)
$labelMaxSize.Text = "Max USB Size (GB):"
$groupOptions.Controls.Add($labelMaxSize)

# Max Size Numeric UpDown
$numericMaxSize = New-Object System.Windows.Forms.NumericUpDown
$numericMaxSize.Location = New-Object System.Drawing.Point(170, 23)
$numericMaxSize.Size = New-Object System.Drawing.Size(70, 20)
$numericMaxSize.Minimum = 1
$numericMaxSize.Maximum = 1000
$numericMaxSize.Value = 32
$groupOptions.Controls.Add($numericMaxSize)

# Status Label
$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Location = New-Object System.Drawing.Point(20, 350)
$labelStatus.Size = New-Object System.Drawing.Size(540, 20)
$labelStatus.Text = "Ready"
$form.Controls.Add($labelStatus)

# Copy Button
$buttonCopy = New-Object System.Windows.Forms.Button
$buttonCopy.Location = New-Object System.Drawing.Point(250, 380)
$buttonCopy.Size = New-Object System.Drawing.Size(100, 30)
$buttonCopy.Text = "Copy Files"
$buttonCopy.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$buttonCopy.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($buttonCopy)

# Function to populate the drives combobox
function Populate-DrivesList {
    $comboBoxDrives.Items.Clear()
    $comboBoxDrives.DisplayMember = "DisplayName"
    $comboBoxDrives.ValueMember = "Drive"
    $usbDrives = Get-USBDrives -MaxSizeGB $numericMaxSize.Value
    
    if ($usbDrives) {
        foreach ($drive in $usbDrives) {
            [void]$comboBoxDrives.Items.Add($drive)
        }
        
        if ($comboBoxDrives.Items.Count -gt 0) {
            $comboBoxDrives.SelectedIndex = 0
            $labelStatus.Text = "Ready"
        }
    } else {
        $labelStatus.Text = "No USB drives found."
    }
}

# Function to add Hach files
function Add-Hach-Files {
    $hachFiles = Get-Location | Get-ChildItem -Filter "*.swu"
    $hachFolders = Get-Location | Get-ChildItem -Directory | Where-Object { $_.Name -in @("Hach", "update")}

    foreach ($file in $hachFiles) {
        [void]$listBoxFiles.Items.Add($file)
    }

    foreach ($folder in $hachFolders) {
        [void]$listBoxFiles.Items.Add($folder)
    }
    
}

# Function to handle the file open dialog
function Add-Files {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Multiselect = $true
    $openFileDialog.InitialDirectory = Get-Location
    $openFileDialog.Title = "Select Files to Copy"
    
    if ($openFileDialog.ShowDialog() -eq "OK") {
        foreach ($file in $openFileDialog.FileNames) {
            [void]$listBoxFiles.Items.Add($file)
        }
    }
}

# Function to handle the folder browser dialog
function Add-Folder {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.SelectedPath = Get-Location
    $folderBrowserDialog.Description = "Select a folder to copy"
    
    if ($folderBrowserDialog.ShowDialog() -eq "OK") {
        [void]$listBoxFiles.Items.Add($folderBrowserDialog.SelectedPath)
    }
}

# Function to copy files
function Copy-FilesToUSB {
    if ($comboBoxDrives.SelectedItem -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Please select a USB drive.", "No Drive Selected", "OK", "Warning")
        return
    }
    
    if ($listBoxFiles.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please add files or folders to copy.", "No Files Selected", "OK", "Warning")
        return
    }
    
    $selectedDrive = $comboBoxDrives.SelectedItem
    $driveLetter = $selectedDrive.Drive
        
    # Copy files
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $buttonCopy.Enabled = $false
    $labelStatus.Text = "Copying files...please wait."
    
    $errors = @()

    for ($i = 0; $i -lt $listBoxFiles.Items.Count; $i++) {
        $item = $itemsToCopy.Items[$i]
        
        try {
            if (Test-Path -Path $item -PathType Container) {
                # Folder
                Copy-Item -Path $item -Destination $driveLetter -Recurse -Force -ErrorAction Stop
            }
            else {
                # File
                Copy-Item -Path $item -Destination $driveLetter -Force -ErrorAction Stop
            }

        }
        catch {
            $errors += "Error copying '$item': $_"
        }

    }
    
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    $buttonCopy.Enabled = $true
    $labelStatus.Visible = $true
    
    if ($errors.Count -gt 0) {
        $labelStatus.Text = "Copy completed with $($errors.Count) errors."
        [System.Windows.Forms.MessageBox]::Show(($errors -join "`n"), "Copy Errors", "OK", "Warning")
    }
    else {
        $labelStatus.Text = "Copy completed successfully!"
        [System.Windows.Forms.MessageBox]::Show("All files were copied successfully.", "Copy Complete", "OK", "Information")
    }
}

# Wire up event handlers
$buttonRefresh.Add_Click({ Populate-DrivesList })
$buttonHachFiles.Add_Click({ Add-Hach-Files })
$buttonAddFiles.Add_Click({ Add-Files })
$buttonAddFolder.Add_Click({ Add-Folder })
$buttonCopy.Add_Click({ Copy-FilesToUSB })
$buttonRemove.Add_Click({
    if ($listBoxFiles.SelectedIndex -ne -1) {
        $listBoxFiles.Items.RemoveAt($listBoxFiles.SelectedIndex)
    }
})
$buttonClear.Add_Click({ $listBoxFiles.Items.Clear() })
$numericMaxSize.Add_ValueChanged({ Populate-DrivesList })

# Initial population of drives
Populate-DrivesList

#Pre-load Hach Files
Add-Hach-Files

# Show the form
[void]$form.ShowDialog()