# Encrypted Journal

This program assists you in creating and maintaining an encrypted text document. I use it to manage a personal journal.

It works by:
1. Copying the encrypted file from Google Drive or other location of your choice. If no such file exists, it creates one.
2. Decrypting the file
3. Opening the file in nano
4. On exit, it re-encrypts the file, copies it to the cloud directory, and removes the local copy

## Installation

Copy the file `journal.sh` to your computer. Edit the file to reflect your preferences: what the filename should be called, the directories where the file is saved, and anything else. 

I use this script on Windows Subsystem for Linux and on a Chromebook. On both devices, Google Drive can be accessed in the `/mnt` folder. Unfortunately, Google Drive does not offer a desktop app for Linux, so you will have to find a workaround if you are a desktop Linux user.

Once the file is on your machine and edited to reflect your preferences, make it executable by running `chmod +x journal.sh`. After that, you can execute the script by entering `./journal.sh`.
