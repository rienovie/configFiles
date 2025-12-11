alias sps="sudo pacman -S"
alias lg="lazygit"
alias u="cd .."
alias x="chmod +x"
alias repo="cd /home/vince/Repos"
alias mcf="cd /home/vince/Repos/configFiles/manage"
alias mcfud="mcf && fish systemToRepo.fish"
alias termHost="bash /home/vince/Scripts/bash/termHost.sh"

unalias ls 2>/dev/null
ls() {
	echo -e "\n\033[36m   $PWD\033[0m (working)\n" && command ls --color="auto" -F "$@" && echo -e "\n\033[36m   $PWD\033[0m (working)\n"
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

unalias s 2>/dev/null
s() {
	cd $HOME/Scripts/$@ || return
	if [ -n "$1" ]; then
		nvim
	fi
}
