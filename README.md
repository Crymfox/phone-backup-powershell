# Phone Photo Backup Script

## Overview

This PowerShell script automates the process of copying photos from a connected phone to a backup directory on your computer. The photos are organized by year and month based on their last modified date. The script efficiently handles large numbers of files and avoids re-copying existing files to save time and resources.

## Features

- **Automatic Directory Creation:** Automatically creates directories for each year and month if they do not exist.
- **Efficient File Copying:** Uses an index to avoid copying files that already exist in the destination directory, improving performance for large backups.
- **Recursive Folder Handling:** Copies files from nested directories on the phone.
- **Error Handling:** Provides informative error messages if the phone is not connected or directories are not found.

## Prerequisites

- A Windows computer with PowerShell installed.
- Your phone connected to the computer and recognized in "This PC" (Windows Explorer).
- Ensure the phone's file transfer mode is enabled (usually MTP mode).

## Script Details

### Functions

- `Create-Dir($path)`: Creates a directory if it does not exist.
- `Get-SubFolder($parentDir, $subPath)`: Retrieves a subfolder within the parent directory.
- `Get-PhoneMainDir($phoneName)`: Finds the root directory of the phone in "This PC".
- `Get-FullPathOfMtpDir($mtpDir)`: Constructs the full path of an MTP directory.
- `Get-ExistingFilesIndex($destDirPath)`: Creates an index of existing files in the destination directory.
- `Check-IfItemExists($existingFilesIndex, $itemName)`: Checks if a file exists in the destination directory using the index.
- `Copy-FromPhoneSource-ToBackup($sourceMtpDir, $destDirPath, $existingFilesIndex)`: Copies files from the phone to the backup directory, utilizing the index to skip existing files.

## Usage

1. **Download the Script:**
   Clone the repository or download the script file to your local machine.

   ```sh
   git clone https://github.com/yourusername/phone-photo-backup.git

2. **Modify the Phone Name:**
   Update the `$phoneName` variable in the script to match the name of your phone as it appears in "This PC".

3. **Run the Script:**
   Open PowerShell and navigate to the directory containing the script. Run the script using the following command:

   ```powershell
   .\BackupPhone.ps1

4. **Verify Backup:**
   Check the destination directory (e.g., `D:\BACKUP\TELEFON_DCIM_ALL`) to verify that the photos have been copied and organized by year and month.

## Acknowledgements
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- Community contributions and feedback
