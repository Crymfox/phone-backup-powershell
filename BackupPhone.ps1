$ErrorActionPreference = [string]"Stop"
$DestDirForPhotos = [string]"C:\BACKUP\TELEFON_DCIM_NEW"
$Summary = [Hashtable]@{NewFilesCount=0; ExistingFilesCount=0}
$phoneName = "Galaxy J5 Pro" # Phone name as it appears in This PC

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

# New function to buffer the files before copying
function Get-MtpFilesBuffered {
    param (
        [Parameter(Mandatory=$true)]
        [Object]$sourceMtpDir
    )
    $files = @()
    $retryCount = 5
    while ($retryCount -gt 0) {
        try {
            $items = $sourceMtpDir.GetFolder.Items()
            if ($items.Count -gt 0) {
                $files += $items | Where-Object { -not $_.IsFolder }
                if ($files.Count -gt 0) {
                    break
                }
            }
        } catch {
            Write-Host "Error retrieving files, retrying..."
        }
        Start-Sleep -Seconds 5
        $retryCount--
    }
    if ($files.Count -eq 0) {
        throw "Failed to retrieve files after multiple attempts."
    }
    return $files
}

function Copy-FromPhoneSource-ToBackup($sourceMtpDir, $destDirPath, $existingFilesIndex) {
    Create-Dir $destDirPath
    $destDirShell = (New-Object -Com Shell.Application).NameSpace($destDirPath)

    $directoriesStack = New-Object System.Collections.Stack
    $directoriesStack.Push(@($sourceMtpDir, $destDirPath))

    while ($directoriesStack.count -gt 0) {
        $currentSourceDestPair = $directoriesStack.Pop()
        $currentSourceDir = $currentSourceDestPair[0]
        $currentDestDir = $currentSourceDestPair[1]

        $fullSourceDirPath = Get-FullPathOfMtpDir $currentSourceDir
        Write-Host "Processing directory: '$fullSourceDirPath'"

        # Use buffered file retrieval
        $files = Get-MtpFilesBuffered -sourceMtpDir $currentSourceDir

        foreach ($item in $files) {
            $itemName = $item.Name
            $fullFilePath = Join-Path -Path $currentDestDir -ChildPath $itemName

            if (Check-IfItemExists $existingFilesIndex $itemName) {
                Write-Host "Element '$itemName' already exists"
                $script:Summary.ExistingFilesCount++
            } else {
                Write-Host ("Copying {0}: {1}" -f $itemName, $fullSourceDirPath)
                $destDirShell.CopyHere($item)
                $script:Summary.NewFilesCount++
            }
        }

        # Handle folders last to ensure all files are copied before stepping into subdirectories
        foreach ($item in $currentSourceDir.GetFolder.Items()) {
            if ($item.IsFolder) {
                $subDestDir = Join-Path $currentDestDir $item.GetFolder.Title
                Create-Dir $subDestDir
                $directoriesStack.Push(@($item, $subDestDir))
            }
        }
    }
    Write-Host "Completed copying files from '$destDirPath'. New files: $($script:Summary.NewFilesCount), Existing files: $($script:Summary.ExistingFilesCount)"
}

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
$files = Get-ChildItem $DestDirForPhotos | Where-Object { -not $_.PSIsContainer }

# List Files which will be moved
$files

# Target Folder where files should be moved to. The script will automatically create a folder for the year and month.
$targetPath = $DestDirForPhotos

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
