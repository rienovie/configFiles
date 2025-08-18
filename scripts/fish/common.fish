#!/usr/bin/env fish

# Input is prompt
# auto appends [Y/n]
# Defaults yes, use 'confirm' for default no
# return 0=yes 1=no
# usage: if affirm "prompt here if needed"
# usage: if not affirm "prompt here if needed"
function affirm
    if test (count $argv) -gt 0
        set affirmPrompt "$argv[1] [Y/n]: "
    else
        set affirmPrompt "Continue? [Y/n]: "
    end

    while true

        read --prompt-str "$affirmPrompt" affirmSelection

        switch $affirmSelection
            case y Y yes Yes YES ''
                return 0
            case n N no No NO
                return 1
            case '*'
                echo "Plese enter valid response."
        end
    end
end

# Input is prompt
# auto appends [y/N]
# Defaults no, use 'affirm' for default yes
# return 0=yes 1=no
# usage: if confirm "prompt here if needed"
# usage: if not confirm "prompt here if needed"
function confirm
    if test (count $argv) -gt 0
        set confirmPrompt "$argv[1] [y/N]: "
    else
        set confirmPrompt "Continue? [y/N]: "
    end

    while true

        read --prompt-str "$confirmPrompt" confirmSelection

        switch $confirmSelection
            case y Y yes Yes YES
                return 0
            case n N no No NO ''
                return 1
            case '*'
                echo "Plese enter valid response."
        end
    end
end

set slowPrintDelay 0.5
# can set delay with set slowPrintDelay 0.5
function slowPrint
    echo -e $argv
    sleep $slowPrintDelay
end
