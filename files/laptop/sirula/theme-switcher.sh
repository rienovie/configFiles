#!/bin/bash

# Sirula Theme Switcher
# Interactive script to browse and apply themes
# AI gen with auto cursor

THEMES_DIR="themes"
CURRENT_THEME="style.css"
BACKUP_THEME="style.css.backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    Sirula Theme Switcher                     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_footer() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Tip: Restart Sirula to see theme changes take effect!       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Function to check if themes directory exists
check_themes_dir() {
    if [ ! -d "$THEMES_DIR" ]; then
        echo -e "${RED}Error: Themes directory '$THEMES_DIR' not found!${NC}"
        echo -e "${YELLOW}Make sure you're running this script from the Sirula config directory.${NC}"
        exit 1
    fi
}

# Function to get theme description from CSS file
get_theme_description() {
    local theme_file="$1"
    local description=""
    
    # Try to extract description from CSS comment
    if [ -f "$theme_file" ]; then
        description=$(head -n 5 "$theme_file" | grep -E "Theme|theme" | sed 's/\/\*//; s/\*\///; s/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
    
    if [ -z "$description" ]; then
        # Fallback: use filename without extension
        description=$(basename "$theme_file" .css | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
    fi
    
    echo "$description"
}

# Function to list available themes
list_themes() {
    echo -e "${BLUE}Available Themes:${NC}"
    echo
    
    local count=1
    local themes=()
    
    # Get all CSS files in themes directory
    while IFS= read -r -d '' file; do
        if [[ "$file" == *.css ]]; then
            themes+=("$file")
            local theme_name=$(basename "$file")
            local description=$(get_theme_description "$file")

            # Check if this is the currently active theme
            if [ -f "$CURRENT_THEME" ] && [ -f "$file" ]; then
                if cmp -s "$CURRENT_THEME" "$file"; then
                    echo -e "${GREEN}  $count) $theme_name${NC} ${YELLOW}← Currently Active${NC}"
                    echo -e "     ${PURPLE}$description${NC}"
                else
                    echo -e "${BLUE}  $count) $theme_name${NC}"
                    echo -e "     ${PURPLE}$description${NC}"
                fi
            else
                echo -e "${BLUE}  $count) $theme_name${NC}"
                echo -e "     ${PURPLE}$description${NC}"
            fi
            echo
            ((count++))
        fi
    done < <(find "$THEMES_DIR" -name "*.css" -print0 | sort -z)
    
    echo -e "${YELLOW}  $count) Exit${NC}"
    echo
}

# Function to apply selected theme
apply_theme() {
    local theme_file="$1"
    local theme_name=$(basename "$theme_file")

    # Create backup of current theme if it exists
    if [ -f "$CURRENT_THEME" ]; then
        cp "$CURRENT_THEME" "$BACKUP_THEME"
        echo -e "${YELLOW}Backup created: $BACKUP_THEME${NC}"
    fi

    # Apply the selected theme
    cp "$theme_file" "$CURRENT_THEME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Theme '$theme_name' applied successfully!${NC}"
        echo -e "${YELLOW}Restart Sirula to see the changes.${NC}"
    else
        echo -e "${RED}✗ Failed to apply theme '$theme_name'${NC}"
        # Restore backup if available
        if [ -f "$BACKUP_THEME" ]; then
            cp "$BACKUP_THEME" "$CURRENT_THEME"
            echo -e "${YELLOW}Restored previous theme from backup.${NC}"
        fi
    fi
}

# Function to restore backup
restore_backup() {
    if [ -f "$BACKUP_THEME" ]; then
        cp "$BACKUP_THEME" "$CURRENT_THEME"
        echo -e "${GREEN}✓ Previous theme restored from backup!${NC}"
    else
        echo -e "${RED}No backup found to restore.${NC}"
    fi
}

# Function to show current theme info
show_current_theme() {
    echo -e "${BLUE}Current Theme Information:${NC}"
    echo

    if [ -f "$CURRENT_THEME" ]; then
        local description=$(get_theme_description "$CURRENT_THEME")
        echo -e "${GREEN}Active theme: $CURRENT_THEME${NC}"
        echo -e "${PURPLE}Description: $description${NC}"

        # Show file size and modification date
        local size=$(du -h "$CURRENT_THEME" | cut -f1)
        local date=$(stat -c "%y" "$CURRENT_THEME" | cut -d' ' -f1)
        echo -e "${CYAN}Size: $size | Modified: $date${NC}"
    else
        echo -e "${RED}No theme file found at $CURRENT_THEME${NC}"
    fi

    if [ -f "$BACKUP_THEME" ]; then
        echo -e "${YELLOW}Backup available: $BACKUP_THEME${NC}"
    fi
    echo
}

# Main menu function
show_menu() {
    while true; do
        clear
        print_header
        show_current_theme
        list_themes

        echo -e "${BLUE}Enter your choice (1-$(( $(find "$THEMES_DIR" -name "*.css" | wc -l) + 1 ))):${NC} "
        read -r choice

        # Validate input
        if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Please enter a valid number.${NC}"
            sleep 2
            continue
        fi

        local theme_count=$(find "$THEMES_DIR" -name "*.css" | wc -l)
        local exit_option=$((theme_count + 1))

        if [ "$choice" -eq "$exit_option" ]; then
            echo -e "${GREEN}Goodbye!${NC}"
            print_footer
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le "$theme_count" ]; then
            # Get the selected theme file
            local selected_theme=$(find "$THEMES_DIR" -name "*.css" | sort | sed -n "${choice}p")
            local theme_name=$(basename "$selected_theme")

            echo -e "${BLUE}Applying theme: $theme_name${NC}"
            apply_theme "$selected_theme"
            echo
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
        else
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            sleep 2
        fi
    done
}

# Main script execution
main() {
    check_themes_dir
    show_menu
}

# Run the script
main "$@" 
