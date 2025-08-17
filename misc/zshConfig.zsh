alias sps="sudo pacman -S"
alias lg="lazygit"
alias gc="git clone --recursive"
alias u="cd .."
alias x="chmod +x"
alias cur="/home/vince/Apps/Cursor/*.AppImage"
alias repo="cd /home/vince/Repos"

unalias ls 2>/dev/null
ls() {
	echo && command ls --color="auto" -F "$@" && echo
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
