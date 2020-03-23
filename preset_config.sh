#!/bin/bash

DIR=$(cd `dirname $0` && pwd)

# ------------------------------------------------------------
# Pre installation check
# ------------------------------------------------------------
preinstall_check() {
	if [[ `whoami` == "root" ]];
	then
		echo "The Script shouldn't be run with root (need to install personal config)"
		echo "Privilege Level will be requested later"
		exit -1
	fi
	
	if [[ -z "$LOG_FILE" ]]
	then
		export LOG_FILE="/tmp/system-preset.log"
	fi

	if [[ -z "$TMP_DIR" ]]
	then
		export TMP="/tmp"
	fi
	
	echo "Install for user: `whoami`"
	echo "Log File path $LOG_FILE"
	echo "Temparory files path $TMP"
	echo ""
}

# ------------------------------------------------------------
# Redirect output
# ------------------------------------------------------------
redirect_output() {
	exec 3>&1
	exec >>$LOG_FILE
	exec 2>>/tmp/system-preset-err.log
	
	# function echo to show echo output on terminal
	echo() {
		command echo "$@" >&3
	}
}

# ------------------------------------------------------------
# git
# ------------------------------------------------------------
install_and_config_git() {
	echo "Installing git"
	yes '' | sudo apt install -y git git-extras
	git config --global core.editor vi
	git config --global color.ui auto
	git config --global push.default simple
	echo -e "Done git installation.\n"
}

# ------------------------------------------------------------
# Personal dedicated theme under xfce4
# materia gtk theme + papirus icon theme +
# elementary console theme + IBM Plex font
# ------------------------------------------------------------
install_theme() {
	echo "Installing theme (takes some time)"
	# refer to https://github.com/nana-4/materia-theme
	# and https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
	yes '' | sudo add-apt-repository ppa:papirus/papirus
	yes '' | sudo add-apt-repository ppa:papirus/hardcode-tray
	yes '' | sudo apt install -y papirus-icon-theme materia-gtk-theme hardcode-tray

	# terminal color scheme
	# refer to https://github.com/Mayccoll/Gogh 
	# Disable because can be configured in config_theme()
	# echo "Installing gnome terminal color scheme"
	# dconf write /org/gnome/terminal/legacy/profiles:/default "''"  # in case dir nonexist
	# wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt
	
	# IBM Plex Font
	echo "Installing IBM Plex Font"
	wget -P $TMP "https://www.fontsquirrel.com/fonts/download/ibm-plex.zip"
	yes 'A' | unzip $TMP/ibm-plex.zip -d $TMP/ibm-plex
	mkdir -p $HOME/.local/share/fonts/ibm-plex
	yes | cp -f $TMP/ibm-plex/*.otf $HOME/.local/share/fonts/ibm-plex
	fc-cache -fv
	rm $TMP/ibm-plex.zip
	rm -rf $TMP/ibm-plex
	
	# Download bg
	echo "Downloading BG"
	wget -P $HOME/Pictures/ https://wallpapershome.com/images/wallpapers/3d-3840x2160-abstract-shapes-glass-4k-17746.jpg
	
	echo "Done theme installation."
}

# this config should be run at the end of installation
config_theme() {
	echo "Configuring theme"
	cp -rf xfce4/xfce4 $HOME/.config/
	cp -rf xfce4/Thunar $HOME/.config/
	cp -rf xfce4/xubuntu $HOME/.config/
	echo "Done theme Configuration."
	echo -e "Reboot to take effect.\n"

}


# ------------------------------------------------------------
# Vim
# ------------------------------------------------------------
install_vim() {
	echo "Installing vim"
	yes '' | sudo apt install -y vim
	echo -e "Done vim installation.\n"
}

config_vim() {
	echo "Configuring vim"
	$DIR/vim/vim_config.sh
	echo -e "Done vim Configuration.\n"
}

# ------------------------------------------------------------
# Tmux
# ------------------------------------------------------------
install_tmux() {
	echo "Installing tmux"
	TMUX_VER=3.0a
	yes '' | sudo apt install -y make autoconf pkg-config libevent-dev libncurses5-dev libncursesw5-dev gcc
	wget -P $TMP https://github.com/tmux/tmux/releases/download/$TMUX_VER/tmux-$TMUX_VER.tar.gz
	tar -xf $TMP/tmux-$TMUX_VER.tar.gz -C $TMP
	cd $TMP/tmux-$TMUX_VER
	./configure && make -j4
	sudo make install
	cd -
	rm -rf $TMP/tmux-$TMUX_VER
	rm -rf $TMP/tmux-$TMUX_VER.tar.gz
	echo -e "Done tmux installation.\n"
}

config_tmux() {
	echo "Configuring tmux"
	yes '' | sudo apt install -y xsel
	mkdir -p $HOME/.tmux/plugins
	wget -P $TMP https://github.com/tmux-plugins/tpm/archive/v3.0.0.tar.gz
	tar -xf $TMP/v3.0.0.tar.gz -C $HOME/.tmux/plugins
	mv $HOME/.tmux/plugins/tpm-3.0.0 $HOME/.tmux/plugins/tpm
	rm -rf $TMP/v3.0.0.tar.gz
	$DIR/tmux/tmux_config.sh
	echo -e "Done tmux Configuration.\n"
}

# ------------------------------------------------------------
# Zsh
# ------------------------------------------------------------
install_zsh() {
	echo "Installing zsh"
	yes '' | sudo apt install -y zsh
	# install oh my zsh
	# prevent changing zsh shell from login
	yes 'n' | sh -c "hash() { return -1; }; `wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -`"
	echo -e "Done zsh installation.\n"
}

config_zsh() {
	echo "Configuring zsh"
	$DIR/shell/shell_config.sh
	echo -e "Done zsh Configuration.\n"
}

# ------------------------------------------------------------
# Universal ctags
# ------------------------------------------------------------
install_ctags() {
	echo "Installing universal ctags"
	yes '' | sudo apt install -y make autoconf pkg-config libevent-dev libncurses5-dev libncursesw5-dev gcc
	wget -P $TMP https://github.com/universal-ctags/ctags/archive/master.zip
	unzip $TMP/master.zip -d $TMP
	cd $TMP/ctags-master
	./autogen.sh 
	./configure && make -j4
	sudo make install
	cd -
	rm -rf $TMP/ctags-master
	rm -rf $TMP/master.zip
	echo -e "Done universal ctags installation.\n"
}

# ------------------------------------------------------------
# Aria2
# ------------------------------------------------------------
install_aria2() {
	echo "Installing aria2"
	yes '' | sudo apt install -y aria2
	mkdir -p ${HOME}/.config/aria2/
	ln -f aria2/aria2.conf ${HOME}/.config/aria2/aria2.conf
	echo -e "Done aria2 installation.\n"
}

# ------------------------------------------------------------
# Fcitx framework
# ------------------------------------------------------------
install_fcitx() {
	echo "Installing fcitx"
	yes '' | sudo apt install -y fcitx fcitx-googlepinyin
	# add environment variable necessary to run
	echo -e "GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=\"@im=fcitx\"\n" | sudo tee -a /etc/environment
	echo -e "Done fcitx installation. (optional: add fcitx to autostart)\n"
}

# ------------------------------------------------------------
# Clean Up
# ------------------------------------------------------------
clean_up() {
	sudo apt autoremove
	exec 3>&-
}
