#!/bin/bash


# ------------------------------------------------------------
# This script is for Ubuntu 16.04
# ------------------------------------------------------------
# load config file
DIR=$(cd `dirname $0` && pwd)
source $DIR/preset_config.sh

preinstall_check
redirect_output

# ------------------------
# Configurable region
# ------------------------

#install_vm_tools
install_and_config_git
install_vim
config_vim
install_tmux
config_tmux
install_ctags
install_aria2
#install_fcitx
install_chrome
#install_brackets
install_theme
config_theme

# ------------------------

clean_up
exit 0

