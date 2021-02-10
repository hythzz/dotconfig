#!/bin/bash


# ------------------------------------------------------------
# This script is for Ubuntu 20.04
# ------------------------------------------------------------
# load config file
DIR=$(cd `dirname $0` && pwd)
source $DIR/preset_config.sh

preinstall_check
redirect_output

# ------------------------
# Configurable region
# ------------------------

install_and_config_git
install_vim
config_vim
install_tmux
config_tmux
install_zsh
config_zsh
install_ctags
install_aria2
install_fcitx
install_theme
# config_theme
install_apps

# ------------------------

clean_up
exit 0

