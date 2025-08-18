#!/usr/bin/env fish

if not test -f "init.fish"
    echo "Please run this script from the manage directory."
    exit 1
end

source "../scripts/fish/common.fish"

# Will set this for the entire script
set slowPrintDelay 1

slowPrint "This is the initialization for this repo."
slowPrint "It should only be run once per system."

if not confirm
    echo "Exiting..."
    exit 1
end

slowPrint "Initializing variables for the repo."

if test -d "vars"
    slowPrint "vars directory already exists."
    slowPrint "This script was probably run before."

    if not confirm "Please verify that you want to continue."
        echo "Exiting..."
        exit 1
    end

    slowPrint "Clearing vars directory..."
    rm -rf "vars/*"

else
    slowPrint "Creating vars directory..."
    mkdir -p "vars"
end

read --prompt-str "What should this system be called? " systemName

while not confirm "The system will be called '$systemName' is that correct?"
    read --prompt-str "What should this system be called? " systemName
end

# NOTE: Not sure if I'll need any other vars, but this is where they'll be initialized
# The initialized file is not currently used, but it's here if needed later
echo "$systemName" > "vars/system"
touch "vars/paths" "vars/initialized"

slowPrint "Checking to see if system config already exists..."

if test -d "../files/$systemName"
    slowPrint "Found system config in '../files/$systemName'"

    if not confirm "Would you like to apply the config found to this system?"
        echo "Exiting..."
        exit 1
    end

    slowPrint "Calling the repoToSystem.fish script..."

    source "repoToSystem.fish"

    slowPrint "Initializing script complete."
    exit 0
else
    mkdir -p "../files/$systemName"

    set copyLoop true
    while $copyLoop
        slowPrint "Would you like to add the current system config to the repo?"
        slowPrint "Or would you like to copy an already existing config to this system?"
        slowPrint "No entry will exit the script."
        slowPrint "'add' will add the current system config to the repo."
        slowPrint "'copy' will ask for name to copy."
        read --prompt-str "Enter your choice: " configApply

        switch $configApply
            case add
                slowPrint "Calling the systemToRepo.fish script..."
                source "systemToRepo.fish"
                set copyLoop false
                continue
            case copy
                while $copyLoop
                    slowPrint "Listing configs in ../files..."
                    ls -d "../files/*"
                    read --prompt-str "What is the name of the config you would like to copy? " configName
                    if test -d "../files/$configName"
                        slowPrint "Copying config..."
                        cp -r "../files/$configName" "../files/$systemName"

                        slowPrint "Calling the repoToSystem.fish script..."
                        source "repoToSystem.fish"

                        set copyLoop false
                        continue
                    else
                        slowPrint "Config not found."
                        continue
                    end
                end
            case '*'
                slowPrint "Invalid option."
                continue
        end
    end

    slowPrint "Initialization script complete."
    exit 0
end

