#!/usr/bin/env bash

# trash_restore.sh - Restore log files from Trash
# Usage: ./trash_restore.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRASH_LOGS_DIR="$HOME/Trash/.logs"

# Source common dialogs
source "$SCRIPT_DIR/common.sh"
[[ $? -ne 0 ]] && { echo "Failed to load common.sh"; exit 1; }

# Set dialog backtitle and title for consistent appearance
BACKTITLE="Trash Restore"
TITLE="Log File Recovery"

# Check if trash logs directory exists
if [[ ! -d "$TRASH_LOGS_DIR" ]]; then
    show_msg "The Trash logs directory does not exist at: $TRASH_LOGS_DIR"
    exit 0
fi

# Collect ALL files and directories in the .logs directory (including nested paths) into array
mapfile -t LOG_FILES < <(find "$TRASH_LOGS_DIR" -type f 2>/dev/null | sort)

if [[ ${#LOG_FILES[@]} -eq 0 ]]; then
    show_msg "No log files found in the Trash logs directory."
    exit 0
fi

# Wrap in loop - continue until user selects a file or cancels all
echo "Select a log file to restore:"

while true; do
    # Build menu items: first entry = filename, second entry = first line content of file
    MENU_ITEMS=()
    for file in "${LOG_FILES[@]}"; do
        short_name=$(basename "$file")

        # Read first line of file content (truncate to 500 chars)
        first_line=$(head -n1 "$file" 2>/dev/null | head -c500)

        # Create menu entry pair: first line is filename, second is first line content
        MENU_ITEMS+=("$short_name"	"$first_line")
    done

    # Display automenu with all available files (each showing 2 lines: filename + first line)
    MENU_CHOICE=$(auto_menu "$TITLE" "Select log file to restore:" "${MENU_ITEMS[@]}")

    if [[ -z "$MENU_CHOICE" ]]; then
        echo "No log file selected."
        break
    fi

    # Get full content of the file to display in yesno dialog
    FILE_CONTENT=$(cat "$TRASH_LOGS_DIR/$MENU_CHOICE" 2>/dev/null)

    # Ask if user wants to restore, showing content in yesno prompt
    CONTENT_SUMMARY="${FILE_CONTENT:0:150}"
    if [[ ${#FILE_CONTENT} -gt 150 ]]; then
        CONTENT_SUMMARY="${CONTENT_SUMMARY}..."
    fi

    if yesno "Restore '$MENU_CHOICE'?\n\nContent:\n$CONTENT_SUMMARY"; then
        # Parse the first line to find target directory path
        TARGET_PATH=$(echo "$FILE_CONTENT" | grep -oE '^[[:space:]]*/[^[:space:]&"]+' | head -n1)

        if [[ -z "$TARGET_PATH" ]]; then
            show_msg "Could not determine restore path."
            echo "Restore cancelled."
            continue
        fi

        TRASH_SOURCE="$TRASH_LOGS_DIR/$MENU_CHOICE"
        RESTORE_TARGET="$TARGET_PATH/"

        # Create parent directory if it doesn't exist
        mkdir -p "$RESTORE_TARGET" 2>/dev/null || {
            show_msg "Failed to create target directory."
            echo "Restore cancelled."
            continue
        }

        echo "Restoring: $TRASH_SOURCE -> $RESTORE_TARGET"

        # Move the log file from Trash to the specified location
        mv "$TRASH_SOURCE" "$RESTORE_TARGET" || {
            show_msg "Failed to restore the file."
            echo "Restore cancelled."
            continue
        }

        show_msg "File '$MENU_CHOICE' has been restored to $TARGET_PATH/"
    else
        echo "Restore cancelled."
    fi
done
