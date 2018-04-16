#!/bin/bash

DIR=$(cd `dirname $0` && pwd)
ln -sf $DIR/dottmux.conf $HOME/.tmux.conf
