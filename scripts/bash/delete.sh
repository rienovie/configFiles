#!/bin/bash

# delete.sh - Move files/directories to $HOME/Trash preserving original path
# Usage: ./delete.sh [file1] [dir2] ...
# Logs are written to $HOME/Trash/.logs/YYYY.MM.DD.HH.MM.SS (newline-separated paths)

SCRIPT_PATH="$(readlink -f "$0")"
TRASH_DIR="$HOME/Trash"
LOG_DIR="$TRASH_DIR/.logs"
LOG_FILE="$TRASH_DIR/.logs/$(date '+%Y.%m.%d.%H.%M.%S')"

# Ensure trash and logs directories exist
mkdir -p "$TRASH_DIR"
mkdir -p "$LOG_DIR"

declare -a FULL_PATHS
if [[ $# -eq 0 ]]; then
    echo "Usage: $SCRIPT_PATH [file1] [dir2] ..." >&2
    echo "Moves files/directories to $TRASH_DIR while preserving full original path." >&2
    exit 1
fi

for item in "$@"; do
    # Check if item exists
    if [[ ! -e "$item" ]]; then
        echo "Error: '$item' does not exist" >&2
        continue
    fi

    # Get full path (for symlinks, resolve them)
    full_path="$(readlink -f "$item")"
    # Store full path in array for logging
    FULL_PATHS+=("$full_path")
    # Remove leading / so we can preserve original path relative to Trash
    rel_path="${full_path#/}"

    # Construct target path in trash
    target_path="$TRASH_DIR/$rel_path"
    # Create parent directory for destination if needed
    mkdir -p "$(dirname "$target_path")"

    # Check if it's a file or directory
    if [[ -f "$item" ]]; then
        # Move to trash
        if mv -- "$full_path" "$target_path"; then
            echo "Moved: '$item' -> '$target_path'"
        else
            echo "Error: Failed to move '$item'" >&2
            continue
        fi
    elif [[ -d "$item" ]]; then
        # For directories, mv handles recursive movement automatically
        if mv -- "$full_path" "$target_path"; then
            echo "Moved: '$item' -> '$target_path'"
        else
            echo "Error: Failed to move '$item'" >&2
            continue
        fi
    else
        echo "Warning: Unknown type of item: '$item'" >&2
        continue
    fi
done

# Write log file with newline-separated full paths of moved items
printf '%s\n' "${FULL_PATHS[@]}" > "$LOG_FILE"

echo ""
echo "Done." >&2
echo "Log written to: $LOG_FILE" >&2
