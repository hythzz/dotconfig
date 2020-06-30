#!/bin/bash

# Author: Yutong Huang
# Date:   Jun 30th, 2020
# 
# inspired by https://gist.github.com/Fordi/e3aa57b91cfef7561e252c2c5b801d0f
# Requires the following packages in Ubuntu:
# wmctrl
# bind this script to your favorite shortcut key and enjoy

dependency_check() {
	if [[ ! -f $(which wmctrl) ]]
	then
		exit
	fi
}

del_workspace_tail() {
	local num_workspace=$(wmctrl -d | wc -l)
	if (( 1 < $num_workspace )); then
		wmctrl -n $(($num_workspace - 1))
	fi
}

main() {
	dependency_check
	del_workspace_tail
}

main
exit 0
