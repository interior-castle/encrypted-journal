# Encrypted Journal

This program assists you in creating and maintaining an encrypted text journal in markdown (`.md`) format. It works by:
1. Copying the encrypted file from Google Drive to your local directory. If no such file exists, it creates one.
2. Decrypting the file using a user-provided password
3. Opening the file in nano
4. On exit, re-encrypting the file, copying it to the cloud directory, and removing the local copy

This allows me to maintain a journal that:
- is private
- is automatically stored in the cloud
- can be edited using multiple devices without version clashes
- does not rely on a proprietary app or file format

Since a journal file can grow long, the script opens the document to the last line with text and automatically inserts a new heading with today's date, so that you can start typing your entry.

## Installation

Ensure that you have `gpg` installed, as that is the utility the script uses for encryption.

Copy the file `journal.sh` to your computer. Edit the file to reflect your preferences: what the filename should be called, the directories where the file is saved and accessed, which text editor you want to use, and anything else.

I use this script on Windows Subsystem for Linux and on a Chromebook. On both devices, Google Drive can be accessed in the `/mnt` folder. Unfortunately, Google Drive does not offer a desktop app for Linux, so you will have to find a workaround if you are a desktop Linux user.

Once the file is on your machine and edited to reflect your preferences, make it executable by running `chmod +x journal.sh`. After that, you can execute the script by entering `./journal.sh`.
