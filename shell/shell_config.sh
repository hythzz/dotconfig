#!/bin/bash

DIR=$(cd `dirname $0` && pwd)
ln -sf $DIR/dotbashrc $HOME/.bashrc
ln -sf $DIR/dotzshrc $HOME/.zshrc
