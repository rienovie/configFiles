alias sps="sudo pacman -S"
alias lg="lazygit"
alias u="cd .."
alias x="chmod +x"
alias cur="/home/vince/Apps/Cursor/*.AppImage"
alias repo="cd /home/vince/Repos"
alias mcf="cd /home/vince/Repos/configFiles/manage"
alias mcfud="mcf && fish systemToRepo.fish"
alias s="cd /home/vince/Scripts"

unalias ls 2>/dev/null
ls() {
	echo -e "\n---$PWD-------------(working)---\n" && command ls --color="auto" -F "$@" && echo -e "\n---$PWD-------------(working)---\n"
}

cd() {
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
}

cf() {
	cd $HOME/.config/$@ || return
	if [ -n "$1" ]; then
		nvim
	fi
}

unalias gc 2>/dev/null
gc() {
	git clone --recursive $@ || { echo "Error with git clone" && return 1 }
	builtin cd $(basename $1 .git) && ls || { echo "Error with cd" && return 1 }
}
