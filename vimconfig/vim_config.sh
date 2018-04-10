#!/bin/bash

ln -sf $HOME/dotconfig/vimconfig/dotvimrc.vim $HOME/.vimrc

# https://github.com/NLKNguyen/papercolor-theme
mkdir -p $HOME/.vim/colors/
ln -sf $HOME/dotconfig/vimconfig/PaperColor.vim $HOME/.vim/colors/PaperColor.vim

# https://github.com/vim-scripts/taglist.vim
mkdir -p $HOME/.vim/plugin
ln -sf $HOME/dotconfig/vimconfig/taglist.vim $HOME/.vim/plugin/taglist.vim

# https://github.com/justinmk/vim-syntax-extra
mkdir -p $HOME/.vim/after/syntax
ln -sf $HOME/dotconfig/vimconfig/c.vim $HOME/.vim/after/syntax/c.vim

