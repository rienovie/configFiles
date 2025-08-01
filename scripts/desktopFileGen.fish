#!/usr/bin/env fish

function affirm
    if test (count $argv) -gt 0
        set affirmPrompt "$argv [Y/n]:"
    else
        set affirmPrompt "Continue? [Y/n]:"
    end
    read --prompt-str "$affirmPrompt" -r affirmSelection

	switch "$affirmSelection"
	case ("" | [Yy])
		echo "Yes"
	case [Nn]
		echo "No"
	case "*"
		echo "Other"
	end
end

printf "\n\nDesktop file generator.\n\nWill place .desktop file in .local/share/applications\n\n"

if test (count $argv) -gt 0
    set inputExec argv[1]
else
    :
end

affirm someArg

# if count $argv
#     printf $argv
# end
