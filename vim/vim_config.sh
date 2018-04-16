#!/bin/bash

DIR=$(cd `dirname $0` && pwd)

ln -sf $DIR/dotvimrc.vim $HOME/.vimrc

# https://github.com/NLKNguyen/papercolor-theme
mkdir -p $HOME/.vim/colors/
ln -sf $DIR/PaperColor.vim $HOME/.vim/colors/PaperColor.vim

# https://github.com/vim-scripts/taglist.vim
mkdir -p $HOME/.vim/plugin
ln -sf $DIR/taglist.vim $HOME/.vim/plugin/taglist.vim

# https://github.com/justinmk/vim-syntax-extra
mkdir -p $HOME/.vim/after/syntax
ln -sf $DIR/c.vim $HOME/.vim/after/syntax/c.vim

