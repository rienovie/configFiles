#!/usr/bin/env bash

# --------------------------------------------------------------------
#  make-desktop.sh – generate a .desktop launcher on demand
#
#  Usage:
#      ./make-desktop.sh -n NAME [-e EXEC] [-i ICON] [-d DESC] [-c CATEGORY]
#                         [-t TRUE|FALSE] [-p PATH]
#
#  Options
#    -n   Name (required)           → Name field in the .desktop file
#    -e   Exec command (default: none)
#    -i   Icon name or path        → Icon field
#    -d   Description              → Comment field
#    -c   Category(s) separated by ';'  → Categories field
#    -t   Terminal?                → Terminal=true|false (defaults to false)
#    -p   Target directory         → where to drop the file
#                                   (default: ~/.local/share/applications/)
#
#  Example:
#      ./make-desktop.sh \
#          -n "My App" \
#          -e "/usr/bin/myapp %u" \
#          -i "/home/me/.icons/myapp.png" \
#          -d "A quick description of My App" \
#          -c "Utility;Development;" \
#          -t false
#
#  The script will create ~/.local/share/applications/My\ App.desktop
# --------------------------------------------------------------------

set -euo pipefail

# Default values
name=""
exec_cmd=""
icon=""
desc=""
category=""
terminal="false"
dest_dir="$HOME/.local/share/applications"

print_usage() {
    cat <<'EOF'
Usage: make-desktop.sh [options]

Options:
  -n NAME          (required) Name of the application
  -e EXEC          Exec command line (default: none)
  -i ICON          Icon name or absolute path
  -d DESC          Description / comment
  -c CATEGORIES    Semicolon‑separated list, e.g. "Utility;Development;"
  -t TRUE|FALSE    Terminal=true|false (defaults to false)
  -p DEST_DIR      Directory where the .desktop file will be written
                  (default: ~/.local/share/applications/)
  -h               Show this help message

The generated file is made executable and its permissions are set to 0644.
EOF
}

# Parse options
while getopts ":n:e:i:d:c:t:p:h" opt; do
    case $opt in
        n) name=$OPTARG ;;
        e) exec_cmd=$OPTARG ;;
        i) icon=$OPTARG ;;
        d) desc=$OPTARG ;;
        c) category=$OPTARG ;;
        t) terminal=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]') ;;
        p) dest_dir=$OPTARG ;;
        h|\?) print_usage; exit 0 ;;
    esac
done

# Validate required fields
if [[ -z $name ]]; then
    echo "Error: -n (Name) is mandatory" >&2
    print_usage
    exit 1
fi

# Prepare the .desktop file name – replace spaces with underscores for safety
file_name="$(printf '%s' "$name" | tr ' ' '_').desktop"
dest_path="$dest_dir/$file_name"

# Create destination directory if it doesn't exist
mkdir -p -- "$dest_dir"

# Build the content line by line (using a here‑document)
cat >"$dest_path" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Terminal=$terminal
$( [[ $exec_cmd ]] && printf 'Exec=%s\n' "$exec_cmd") || printf '#Exec=\n'
$( [[ $icon ]]   && printf 'Icon=%s\n' "$icon") || printf '#Icon=\n'
$( [[ $desc ]]   && printf 'Comment=%s\n' "$desc") || printf '#Comment=\n'
$( [[ $category ]] && printf 'Categories=%s\n' "$category") || printf '#Categories=\n'
EOF

# Make the file executable (required for many desktop environments)
chmod 0644 "$dest_path"

echo "Created: $dest_path"
