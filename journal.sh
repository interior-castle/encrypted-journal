#!/bin/bash

# journal.sh - A portable, encrypted Markdown journal
# Released under CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
# See <https://creativecommons.org/publicdomain/zero/1.0/> for details
# Developed with assistance from Grok, created by xAI

# Define file paths
BASE_PATH="$HOME/Documents/journal"
ENCRYPTED_FILE="$BASE_PATH.gpg"  # Local temp file
DECRYPTED_FILE="$BASE_PATH.md"   # Local temp file
GDRIVE_DIR="/mnt/chromeos/GoogleDrive/MyDrive/documents"  # Adjust for your system
GDRIVE_CANONICAL="$GDRIVE_DIR/journal.gpg"                 # Canonical file in Google Drive

# Function to log messages consistently
log_message() {
  echo "[journal] $1"
}

# Function to handle cleanup and backup
cleanup() {
  # Re-encrypt the file if it exists (should always exist post-edit due to trap)
  log_message "Encrypting $DECRYPTED_FILE to $ENCRYPTED_FILE..."
  gpg -c --batch --yes --passphrase-fd 0 -o "$ENCRYPTED_FILE" "$DECRYPTED_FILE" <<EOF
$PASSWORD
EOF
  if [ $? -eq 0 ] && [ -f "$ENCRYPTED_FILE" ]; then
    log_message "Encryption successful."
  else
    log_message "Encryption failed. GPG error code: $?"
    rm -f "$DECRYPTED_FILE"
    exit 1
  fi

  # Remove the decrypted file
  rm -f "$DECRYPTED_FILE"

  # Copy to Google Drive (canonical location)
  if [ -d "$GDRIVE_DIR" ]; then
    log_message "Copying $ENCRYPTED_FILE to $GDRIVE_CANONICAL..."
    cp "$ENCRYPTED_FILE" "$GDRIVE_CANONICAL"
    if [ $? -eq 0 ]; then
      log_message "Backed up to Google Drive at $GDRIVE_CANONICAL."
      rm -f "$ENCRYPTED_FILE"  # Delete local copy only if upload succeeds
      log_message "Local copy removed; Google Drive is now canonical."
    else
      log_message "Failed to back up to Google Drive. Copy error code: $?"
    fi
  else
    log_message "Google Drive directory not found at $GDRIVE_DIR."
  fi
}

# Trap to ensure cleanup happens even if script is interrupted
trap cleanup EXIT

# Check if Google Drive canonical file exists and copy it locally
if [ -f "$GDRIVE_CANONICAL" ]; then
  log_message "Fetching canonical file from Google Drive..."
  cp "$GDRIVE_CANONICAL" "$ENCRYPTED_FILE"
  if [ $? -ne 0 ]; then
    log_message "Failed to copy from Google Drive. Aborting."
    exit 1
  fi
  # Prompt for password and decrypt
  read -s -p "[journal] Enter password to decrypt: " PASSWORD
  echo
  gpg -d --batch --yes --passphrase-fd 0 -o "$DECRYPTED_FILE" "$ENCRYPTED_FILE" <<EOF
$PASSWORD
EOF
  if [ $? -ne 0 ]; then
    log_message "Decryption failed. Wrong password or corrupted file."
    rm -f "$ENCRYPTED_FILE"
    exit 1
  fi
else
  # If no encrypted file exists in Google Drive, create a new empty journal
  touch "$DECRYPTED_FILE"
  log_message "Created new journal file (no Google Drive copy found)."

  # Prompt for a new password
  read -s -p "[journal] Enter a new password for encryption: " PASSWORD
  echo
fi

# Add custom date header before opening nano
if [ -s "$DECRYPTED_FILE" ]; then
  # Find the last non-empty line number
  LAST_NON_BLANK=$(grep -n "." "$DECRYPTED_FILE" | tail -n 1 | cut -d: -f1)
  if [ -n "$LAST_NON_BLANK" ]; then
    # Append date in format # DOW MM/DD/YY (e.g., # Sat 3/15/25) with two line breaks before and one after
    DATE_STR=$(date '+%a %-m/%d/%y')
    sed -i "${LAST_NON_BLANK}r /dev/stdin" "$DECRYPTED_FILE" <<EOF

# ${DATE_STR}

EOF
    nano +"$((LAST_NON_BLANK + 4))" "$DECRYPTED_FILE"  # Open on first blank line after date (2 before + 1 for date + 1 after)
  else
    # If no non-blank lines, add date at top
    DATE_STR=$(date '+%a %-m/%d/%y')
    echo -e "# ${DATE_STR}\n\n" > "$DECRYPTED_FILE"
    nano +3 "$DECRYPTED_FILE"  # 1 for date + 2 for two newlines (1 after + 1 extra)
  fi
else
  # Empty file, add initial date
  DATE_STR=$(date '+%a %-m/%d/%y')
  echo -e "# ${DATE_STR}\n\n" > "$DECRYPTED_FILE"
  nano +3 "$DECRYPTED_FILE"  # 1 for date + 2 for two newlines (1 after + 1 extra)
fi

# The cleanup function will handle encryption and backup when nano exits
