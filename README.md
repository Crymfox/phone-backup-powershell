# Phone to Backup Directory Sync Script

## Overview

This PowerShell script automates the process of copying photos from your phone's `DCIM/Camera` directory to a backup directory on your computer. The script organizes the photos by year and month based on the last modified date. It is designed to handle large numbers of files and folders and includes optimizations for managing the loading of files via MTP (Media Transfer Protocol).

## Features

- **File Synchronization**: Copies only new or modified files from your phone to the backup directory.
- **Organized Storage**: Automatically organizes photos into folders by year and month.
- **Efficient Indexing**: Utilizes an index of existing files to avoid duplicate copies.
- **Iterative Directory Traversal**: Uses an iterative approach to process directories, avoiding the pitfalls of recursion with large file sets.
- **MTP Buffering**: The script attempts to optimize the loading of files over MTP by buffering a specified number of files during the transfer process.

## Prerequisites

- PowerShell 5.0 or higher
- A Windows PC with MTP support
- A USB connection between your phone and PC
- Enable developer mode on your phone and ensure USB debugging is active.

## Usage

1. **Download the Script:**
   Clone the repository or download the script file to your local machine.

   ```sh
   git clone https://github.com/Crymfox/phone-backup-powershell.git
   ```

2. **Modify the Phone Name:**
   Update the `$phoneName` variable in the script to match the name of your phone as it appears in "This PC".

3. **Run the Script:**
   Open PowerShell and navigate to the directory containing the script. Run the script using the following command:

   ```powershell
   .\BackupPhone.ps1
   ```

4. **Verify Backup:**
   Check the destination directory (e.g., `D:\BACKUP\TELEFON_DCIM_ALL`) to verify that the photos have been copied and organized by year and month.

5. **Important Notes:**
   - *MTP Loading:* The script attempts to optimize the loading of files from the phone over MTP. If your phone has a large number of files, it may take some time for all files to become accessible.
   - *USB Mass Storage:* If available, consider switching to USB Mass Storage mode for faster access to files.

## Additional Script: BackupScriptAdb.ps1

For users with a large number of files on their phone, the `BackupScriptAdb.ps1` script can be used to speed up future synchronizations by moving files directly on the phone after running the main backup script.

### What It Does

The `BackupScriptAdb.ps1` script automates the organization of photos on your phone by moving them into folders based on their last modified date. By doing this, the next time you run the main backup script, the sync process will be faster because the files are already organized.

### Prerequisites for ADB Script

- **ADB Installed:** Ensure you have ADB (Android Debug Bridge) installed on your computer. You can download it as part of the Android SDK Platform Tools [here](https://developer.android.com/studio/releases/platform-tools).
- **Device Drivers:** Install the appropriate USB drivers for your device. This is crucial for ADB to recognize your phone.
- **USB Debugging:** Ensure that USB Debugging is enabled on your phone. This option is usually found in the Developer Options menu on your device.

### Usage

1. **Run the Main Backup Script First:**
   Before running the ADB script, make sure to run the main `BackupPhone.ps1` script to back up your photos to your PC.

2. **Run the ADB Backup Script:**
   After running the main script, you can run the ADB script to organize the files on your phone:
   
   ```powershell
   .\BackupScriptAdb.ps1
   ```

3. **Verify Organization:**
   The photos on your phone should now be organized into folders by year and month. This will make future backups more efficient.

## Troubleshooting

- **ADB Issues:** If the ADB script doesn't run as expected, ensure that ADB is correctly installed and that your device is recognized by ADB (use `adb devices` to check).

## License
   This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/license/mit) file for details.

## Acknowledgements
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- Community contributions and feedback
