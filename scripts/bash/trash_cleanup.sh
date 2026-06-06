#!/bin/bash

# Script to automatically delete files/directories listed in old log files
# Log files are in $HOME/Trash/.logs and contain paths appended to $HOME/Trash
# Only log files older than 30 days (by filename timestamp) are processed

LOGS_DIR="${HOME}/Trash/.logs"
TRASH_DIR="${HOME}/Trash"
CUTOFF_DAYS=30

if [[ ! -d "$LOGS_DIR" ]]; then
    echo "Directory $LOGS_DIR does not exist."
    exit 0
fi

echo "Checking for log files older than $CUTOFF_DAYS days in $LOGS_DIR..."

for logfile in "$LOGS_DIR"/*; do
    [[ -f "$logfile" ]] || continue

    filename=$(basename "$logfile")

    # Parse date: year.month.day.hour.min.sec
    if ! [[ "$filename" =~ ^([0-9]{4})\.([0-9]{2})\.([0-9]{2})\.([0-9]{2})\.([0-9]{2})\.([0-9]{2})$ ]]; then
        continue
    fi

    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
    hour="${BASH_REMATCH[4]}"
    min="${BASH_REMATCH[5]}"
    sec="${BASH_REMATCH[6]}"

    file_timestamp="$year-$month-$day $hour:$min:$sec"

    echo "Checking logfile: $filename ($file_timestamp)"

    # Check if filename date is older than 30 days
    file_epoch=$(date -d "$file_timestamp" '+%s' 2>/dev/null) || continue
    cutoff_epoch=$(date -d "-${CUTOFF_DAYS} days" '+%s' 2>/dev/null) || continue

    if [[ $file_epoch -lt $cutoff_epoch ]]; then
        echo "OLD LOGFILE: $filename ($file_timestamp)"

        # Read each line from the log file and delete
        while IFS= read -r path; do
            # Trim whitespace
            path=$(echo "$path" | tr -d '[:space:]')
            [[ -n "$path" ]] || continue

            # Build full path (append to $TRASH_DIR)
            full_path="${TRASH_DIR}/${path}"

            if [[ -e "$full_path" ]]; then
                echo "DELETED: $(basename "$full_path")"
                rm -rf "$full_path"
            else
                echo "SKIP (not found): $full_path"
            fi
        done < "$logfile"

        # Also delete the log file itself
        echo "DELETED logfile: $logfile"
        rm "$logfile"
    fi
done

echo "Cleanup complete."

# Remove empty directories (safely, starting from Trash)
echo "Removing empty directories..."
find "$TRASH_DIR" -type d -empty -delete 2>/dev/null || true
echo "Empty directory removal complete."
