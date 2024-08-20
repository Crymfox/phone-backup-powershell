# Define the directory on the phone where photos are stored
$phoneDir = "/sdcard/DCIM/Camera"
$sortedDir = "/sdcard/DCIM/Sorted"

# Fetch the list of files along with their last modification time
$adbCommand = "adb shell find $phoneDir -type f"
$files = Invoke-Expression $adbCommand

foreach ($file in $files) {
    # Ensure the line contains a file path
    if ($file) {
        # Remove any extraneous whitespace or newlines
        $file = $file.Trim()
        
        # Get the modification date of the file
        $modDateCommand = "adb shell date +%Y/%m -r `"$file`""
        $modDate = Invoke-Expression $modDateCommand

        # Check if date retrieval was successful
        if ($modDate -ne $null -and $modDate.Trim()) {
            $modDate = $modDate.Trim() # Remove any extraneous whitespace or newline
            $modDate = $modDate -replace ' ', '' # Remove spaces if present
            
            # Construct the target directory
            $targetDir = "$sortedDir/$modDate"
            $fileName = [System.IO.Path]::GetFileName($file)

            # Create the directory if it doesn't exist
            $mkdirCommand = "adb shell mkdir -p `"$targetDir`""
            Write-Host "Executing: $mkdirCommand"
            Invoke-Expression $mkdirCommand

            # Move the file to the target directory
            $moveCommand = "adb shell mv `"$file`" `"$targetDir/$fileName`""
            Write-Host "Executing: $moveCommand"
            $moveResult = Invoke-Expression $moveCommand

            # Check if the file has been successfully moved
            $checkFileCommand = "adb shell '[ -e `"$targetDir/$fileName`" ] && echo Success || echo Failed'"
            $checkFile = Invoke-Expression $checkFileCommand
            Write-Host "Move result for $fileName: $checkFile"
        } else {
            Write-Host "Date retrieval failed for $file. Skipping file."
        }
    } else {
        Write-Host "No valid file path found. Skipping line."
    }
}
