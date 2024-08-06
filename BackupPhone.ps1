$ErrorActionPreference = [string]"Stop"
$DestDirForPhotos = [string]"D:\BACKUP\TELEFON_DCIM_ALL"
$Summary = [Hashtable]@{NewFilesCount=0; ExistingFilesCount=0}

function Create-Dir($path) {
    if (!(Test-Path -Path $path)) {
        Write-Host "Creating: $path"
        New-Item -Path $path -ItemType Directory
    } else {
        Write-Host "Path $path already exists"
    }
}

function Get-SubFolder($parentDir, $subPath) {
    $result = $parentDir
    foreach ($pathSegment in ($subPath -split "\\")) {
        $result = $result.GetFolder.Items() | Where-Object { $_.Name -eq $pathSegment } | select -First 1
        if ($result -eq $null) {
            throw "Not found $subPath folder"
        }
    }
    return $result
}

function Get-PhoneMainDir($phoneName) {
    $o = New-Object -com Shell.Application
    $rootComputerDirectory = $o.NameSpace(0x11)
    $phoneDirectory = $rootComputerDirectory.Items() | Where-Object { $_.Name -eq $phoneName } | select -First 1

    if ($phoneDirectory -eq $null) {
        throw "Not found '$phoneName' folder in This computer. Connect your phone."
    }

    return $phoneDirectory
}

function Get-FullPathOfMtpDir($mtpDir) {
    $fullDirPath = ""
    $directory = $mtpDir.GetFolder
    while ($directory -ne $null) {
        $fullDirPath = -join($directory.Title, '\', $fullDirPath)
        $directory = $directory.ParentFolder
    }
    return $fullDirPath
}

function Get-ExistingFilesIndex($destDirPath) {
    $existingFiles = @{}
    if (!(Test-Path -Path $destDirPath)) {
        Write-Host "Destination directory does not exist: $destDirPath"
        return $existingFiles
    }

    $shell = New-Object -Com Shell.Application
    $destFolder = $shell.NameSpace($destDirPath)

    if (-not $destFolder) {
        throw "Failed to access destination directory: $destDirPath"
    }

    function Add-FilesToIndex($folder) {
        foreach ($subItem in $folder.Items()) {
            if (-not $subItem.IsFolder) {
                $existingFiles[$subItem.Name] = $true
            }
            if ($subItem.IsFolder) {
                Add-FilesToIndex $subItem.GetFolder
            }
        }
    }

    Add-FilesToIndex $destFolder
    return $existingFiles
}

function Check-IfItemExists($existingFilesIndex, $itemName) {
    return $existingFilesIndex.ContainsKey($itemName)
}

function Copy-FromPhoneSource-ToBackup($sourceMtpDir, $destDirPath, $existingFilesIndex) {
    Create-Dir $destDirPath
    $destDirShell = (New-Object -Com Shell.Application).NameSpace($destDirPath)
    $fullSourceDirPath = Get-FullPathOfMtpDir $sourceMtpDir

    Write-Host "Copying from: '$fullSourceDirPath' to '$destDirPath'"

    $copiedCount = 0
    $existingCount = 0

    foreach ($item in $sourceMtpDir.GetFolder.Items()) {
        $itemName = $item.Name
        $fullFilePath = Join-Path -Path $destDirPath -ChildPath $itemName

        if ($item.IsFolder) {
            Write-Host "$itemName is a folder, stepping into"
            Copy-FromPhoneSource-ToBackup $item (Join-Path $destDirPath $item.GetFolder.Title) $existingFilesIndex
        } elseif (Check-IfItemExists $existingFilesIndex $itemName) {
            Write-Host "Element '$itemName' already exists"
            $existingCount++
        } else {
            $copiedCount++
            Write-Host ("Copying #{0}: {1}{2}" -f $copiedCount, $fullSourceDirPath, $item.Name)
            $destDirShell.CopyHere($item)
        }
    }

    $script:Summary.NewFilesCount += $copiedCount
    $script:Summary.ExistingFilesCount += $existingCount
    Write-Host "Copied '$copiedCount' elements from '$fullSourceDirPath'"
}

$phoneName = "Galaxy J5 Pro" # Phone name as it appears in This PC
$phoneRootDir = Get-PhoneMainDir $phoneName

# Create the index of existing files
$existingFilesIndex = Get-ExistingFilesIndex $DestDirForPhotos

# Ensure the index is always initialized
if ($null -eq $existingFilesIndex) {
    $existingFilesIndex = @{}
}

# Check if index creation was successful
if ($existingFilesIndex.Count -eq 0) {
    Write-Host "No files indexed. Either the directory is empty or indexing failed."
} else {
    Write-Host "Index created with $($existingFilesIndex.Count) files."
}

# Start the copy process using the index
Copy-FromPhoneSource-ToBackup (Get-SubFolder $phoneRootDir "Phone\DCIM\Camera") $DestDirForPhotos $existingFilesIndex

# Get the files which should be moved, without folders
$files = Get-ChildItem 'D:\BACKUP\TELEFON_DCIM_ALL' | Where-Object { -not $_.PSIsContainer }

# List Files which will be moved
$files

# Target Folder where files should be moved to. The script will automatically create a folder for the year and month.
$targetPath = 'D:\BACKUP\TELEFON_DCIM_ALL'

foreach ($file in $files) {
    # Get year and Month of the file
    # I used LastWriteTime since these are synced files and the creation day will be the date when it was synced
    $year = $file.LastWriteTime.Year.ToString()
    $month = $file.LastWriteTime.Month.ToString()

    # Output FileName, year and month
    $file.Name
    $year
    $month

    # Set Directory Path
    $Directory = $targetPath + "\" + $year + "\" + $month
    # Create directory if it doesn't exist
    if (!(Test-Path $Directory)) {
        New-Item $directory -type directory
    }

    # Move File to new location
    $file | Move-Item -Destination $Directory
}

write-host ($Summary | out-string)
