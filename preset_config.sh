#!/bin/bash

DIR=$(cd `dirname $0` && pwd)

# ------------------------------------------------------------
# Pre installation check
# ------------------------------------------------------------
preinstall_check() {
	if [[ `whoami` == "root" ]];
	then
		echo "The Script shouldn't be run with root"
		exit -1
	fi
	
	if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]];
	then
		echo "Please export GIT_USER_NAME and GIT_USER_EMAIL"
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
	echo "Git user name: $GIT_USER_NAME"
	echo "Git user email: $GIT_USER_EMAIL"
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
	exec 2>>$LOG_FILE
	
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
	sudo apt-get update
	yes '' | sudo apt-get install git git-extras
	git config --global user.name "$GIT_USER_NAME"
	git config --global user.email "$GIT_USER_EMAIL"
	git config --global core.editor vi
	git config --global color.ui auto
	git config --global push.default simple
	echo -e "Done git installation.\n"
}

# ------------------------------------------------------------
# vmware tools
# ------------------------------------------------------------
install_vm_tools() {
	echo "Installing VMware tools"
	yes '' | sudo apt-get install open-vm-tools open-vm-tools-desktop
	echo -e "Done VMware tools installation.\n"
}

# ------------------------------------------------------------
# Personal dedicated theme (only tested on ubuntu 16.04)
# papirus icon theme + materia gtk theme + capitaine cursor +
# elementary console theme + IBM Plex font
# ------------------------------------------------------------
install_theme() {
	echo "Installing theme (takes some time)"
	# papirus repo
	# Capitaine cursors repo
	yes '' | sudo add-apt-repository ppa:papirus/papirus
	yes '' | sudo add-apt-repository ppa:dyatlov-igor/la-capitaine
	sudo apt-get update

	echo "Installing UI tweak tools"
	yes '' | sudo apt-get install unity-tweak-tool dconf-cli
	
	echo "Installing papirus icon theme"
	yes '' | sudo apt-get install papirus-icon-theme
	
	# refer to https://github.com/keeferrourke/capitaine-cursors
	echo "Installing capitaine cursor theme"
	yes '' | sudo apt-get install la-capitaine-cursor-theme
	
	# refer to https://github.com/nana-4/materia-theme
	echo "Installing materia gtk theme"
	yes '' | sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf libxml2-utils
	wget -P $TMP https://github.com/nana-4/materia-theme/archive/v20180321.tar.gz
	tar -xf $TMP/v20180321.tar.gz -C $TMP
	cd $TMP/materia-theme-20180321/
	sudo ./install.sh
	cd -
	rm -rf $TMP/materia-theme-20180321
	rm -rf $TMP/v20180321.tar.gz

	# terminal color scheme
	# refer to https://github.com/Mayccoll/Gogh 
	echo "Installing gnome terminal color scheme"
	wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt
	
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
	wget -P $HOME/Pictures/ http://www.hd-freeimages.com/uploads/large/4k-abstract/4k-abstract-hd-wallpaper.jpg
	wget -P $HOME/Pictures/ https://wallpapershome.com/images/wallpapers/3d-3840x2160-abstract-shapes-glass-4k-17746.jpg
	
	echo -e "Done theme installation.\n"
}

# this config should be run at the end of installation
config_theme() {
	echo "Configuring theme"
	gsettings set org.gnome.desktop.wm.preferences theme 'Materia'
	gsettings set org.gnome.desktop.interface gtk-theme 'Materia'
	gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
	gsettings set org.gnome.desktop.interface cursor-theme 'Capitaine'
	gsettings set org.gnome.desktop.interface cursor-size 24 
	gsettings set org.gnome.desktop.interface font-name 'IBM Plex Sans 11'
	gsettings set org.gnome.desktop.interface document-font-name 'IBM Plex Sans 11'
	gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 11'
	gsettings set org.gnome.desktop.wm.preferences titlebar-font 'IBM Plex Sans Semi-Bold Italic 11'
	gsettings set org.gnome.desktop.background color-shading-type 'solid'
	gsettings set org.gnome.desktop.background picture-uri 'file:///home/hythzz/Pictures/3d-3840x2160-abstract-shapes-glass-4k-17746.jpg'
	dconf write /com/canonical/unity/launcher/favorites "['application://org.gnome.Nautilus.desktop', \
							      'application://firefox.desktop', \
							      'application://chromium-browser.desktop', \
							      'application://libreoffice-writer.desktop', \
							      'application://gnome-terminal.desktop', \
							      'unity://running-apps', \
							      'unity://expo-icon', \
							      'unity://devices']"
	# Disable alt key HUD shortcuts for tmux prefix
	dconf write /org/compiz/integrated/show-hud "['Disabled']"
	echo -e "Done theme Configuration.\n"
}

# ------------------------------------------------------------
# Vim
# ------------------------------------------------------------
install_vim() {
	echo "Installing vim"
	yes '' | sudo add-apt-repository ppa:jonathonf/vim
	sudo apt-get update
	yes '' | sudo apt-get install vim
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
	sudo apt-get update
	yes '' | sudo apt-get install make autoconf pkg-config libevent-dev libncurses5-dev libncursesw5-dev gcc
	wget -P $TMP https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
	tar -xf $TMP/tmux-2.7.tar.gz -C $TMP
	cd $TMP/tmux-2.7
	./configure && make -j4
	sudo make install
	cd -
	rm -rf $TMP/tmux-2.7
	rm -rf $TMP/tmux-2.7.tar.gz
	echo -e "Done tmux installation.\n"
}

config_tmux() {
	echo "Configuring tmux"
	sudo apt-get update
	yes '' | sudo apt-get install xsel
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
	sudo apt-get update
	yes '' | sudo apt-get install zsh
	# install oh my zsh
	sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
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
	sudo apt-get update
	yes '' | sudo apt-get install make autoconf pkg-config libevent-dev libncurses5-dev libncursesw5-dev gcc
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
	echo "Installing aria2 (need compilation, takes some time)"
	sudo apt-get update
	yes '' | sudo apt-get install libgnutls-dev nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev \
				      libxml2-dev zlib1g-dev libsqlite3-dev pkg-config libcppunit-dev \
				      autoconf automake autotools-dev autopoint libtool
	wget -P $TMP https://github.com/aria2/aria2/archive/release-1.33.1.tar.gz
	tar -xf $TMP/release-1.33.1.tar.gz -C $TMP
	cd $TMP/aria2-release-1.33.1
	autoreconf -i
	./configure
	make -j4
	sudo make install
	cd -
	rm -rf $TMP/aria2-release-1.33.1
	rm -rf $TMP/release-1.33.1.tar.gz
	echo -e "Done aria2 installation.\n"
}

# ------------------------------------------------------------
# Fcitx framework
# ------------------------------------------------------------
install_fcitx() {
	echo "Installing fcitx"
	sudo apt-get update
	yes '' | sudo apt-get install fcitx fcitx-googlepinyin
	echo -e "Done fcitx installation. (change settings and reboot)\n"
}

# ------------------------------------------------------------
# Google Chrome
# ------------------------------------------------------------
install_chrome() {
	echo "Installing chromium"
	sudo apt-get update
	yes '' | sudo apt-get install chromium-browser
	echo -e "Done chromium installation.\n"
}

# ------------------------------------------------------------
# Adobe brackets
# ------------------------------------------------------------
install_brackets() {
	echo "Installing Adobe Brackets"
	yes '' | sudo add-apt-repository ppa:webupd8team/brackets
	sudo apt-get update
	yes '' | sudo apt-get install brackets
	echo -e "Done Adobe Brackets installation.\n"
}

# ------------------------------------------------------------
# Clean Up
# ------------------------------------------------------------
clean_up() {
	sudo apt-get autoremove
	exec 3>&-
}
