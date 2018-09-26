#!/bin/bash

DIR=$(cd `dirname $0` && pwd)
ln -sf $DIR/dottmux.conf $HOME/.tmux.conf

# clone TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
