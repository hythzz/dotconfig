#!/bin/bash

##############################################################
# This script is for Ubuntu 16.04
# Pre installation check
##############################################################

if [[ `whoami` == "root" ]];
then
	echo "The Script shouldn't be run with root"
	exit -1
fi

##############################################################
# Install vmware tools
##############################################################
echo -n "Does this Ubuntu run on vmware? (Y/n) "
read choice
sudo apt-get update
if [[ -z $choice || $choice == "Y" ]];
then
	sudo apt-get install open-vm-tools open-vm-tools-desktop
fi
echo -e "Done VMware tools installation.\n"

##############################################################
# Basic Tools
##############################################################
echo "Start git installation"
sudo apt-get install git
echo -e "Done git installation.\n"

echo "Start vim installation"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update 
sudo apt-get install vim
echo -e "Done vim installation.\n"

##############################################################
# Theme
##############################################################
echo "Start theme installation"
# papirus repo
sudo add-apt-repository ppa:papirus/papirus
# paper repo
sudo add-apt-repository ppa:snwh/pulp

sudo apt-get update
sudo apt-get install papirus-icon-theme paper-cursor-theme
# unity tweak tool
sudo apt-get install gnome-tweak-tool

# refer to https://github.com/nana-4/materia-theme
sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf libxml2-utils
git clone https://github.com/nana-4/materia-theme.git /tmp/materia-theme/
cd /tmp/materia-theme/
sudo `pwd`/install.sh
cd -
rm -rf /tmp/materia-theme

# terminal color scheme
# refer to https://github.com/Mayccoll/Gogh 
sudo apt-get install dconf-cli
wget -O xt  http://git.io/v3D8R && chmod +x xt && ./xt && rm xt

# IBM Plex Font
wget -P /tmp "https://www.fontsquirrel.com/fonts/download/ibm-plex.zip"
unzip /tmp/ibm-plex.zip -d /tmp/ibm-plex/
rm /tmp/ibm-plex.zip
mkdir -p $HOME/.local/share/fonts/ibm-plex/
cp /tmp/ibm-plex/*.otf $HOME/.local/share/fonts/ibm-plex/
fc-cache -fv

# Download bg
wget -P $HOME/Pictures/ http://www.hd-freeimages.com/uploads/large/4k-abstract/4k-abstract-hd-wallpaper.jpg

# clean up
sudo apt autoremove
echo -e "Done theme installation.\n"

##############################################################
# Frequent used app
##############################################################

echo "Start Adobe Brackets installation"
sudo add-apt-repository ppa:webupd8team/brackets
sudo apt-get update
sudo apt-get install brackets
echo -e "Done Adobe Brackets installation.\n"

sudo apt-get purge firefox

echo "Start universal tags installation"
sudo apt-get install autoconf
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh 
./configure
make
sudo make install
