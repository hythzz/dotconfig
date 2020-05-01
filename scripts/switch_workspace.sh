#!/bin/bash

# input argument
# $1: direction
#     0: forward
#     1: backward

workspace=$(wmctrl -d | grep " \* " | cut -d ' ' -f 1)
num_workspace=$(wmctrl -d | wc -l)

if (( $1 == 0 )); then
	if (( $workspace < $num_workspace-1 )); then
		workspace=$(( $workspace + 1 ))
		wmctrl -s $workspace
	fi
else
	if (( $workspace > 0 )); then
		workspace=$(( $workspace - 1 ))
		wmctrl -s $workspace
	fi
fi

exit 0

