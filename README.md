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
   git clone https://github.com/yourusername/phone-backup-powershell.git

2. **Modify the Phone Name:**
   Update the `$phoneName` variable in the script to match the name of your phone as it appears in "This PC".

3. **Run the Script:**
   Open PowerShell and navigate to the directory containing the script. Run the script using the following command:

   ```powershell
   .\BackupPhone.ps1

4. **Verify Backup:**
   Check the destination directory (e.g., `D:\BACKUP\TELEFON_DCIM_ALL`) to verify that the photos have been copied and organized by year and month.

5. **Important Notes:**
   - *MTP Loading:* The script attempts to optimize the loading of files from the phone over MTP. If your phone has a large number of files, it may take some time for all files to become accessible.
   - *USB Mass Storage:* If available, consider switching to USB Mass Storage mode for faster access to files.

## Troubleshooting

- **Files Not Copying:** If the script doesn't copy all files, ensure that MTP has fully loaded the directory contents before running the script. Alternatively, open the folder in File Explorer to prompt MTP to load files faster.
- **File Not Found Errors:** If specific files aren't found, it may be due to MTP not loading them in time. Ensure that your phone is fully connected and that all files are visible in File Explorer.

## License
   This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/license/mit) file for details.

## Acknowledgements
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- Community contributions and feedback
