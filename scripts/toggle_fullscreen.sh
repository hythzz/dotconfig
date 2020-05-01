#!/bin/bash

# Author: Yutong Huang
# Date:   May 1st, 2020
# 
# inspired by https://gist.github.com/Fordi/e3aa57b91cfef7561e252c2c5b801d0f
# Requires the following packages in Ubuntu:
# xdotool x11-utils wmctrl
# bind this script to your favorite shortcut key and enjoy

# Behavior expectation:
# 1. script has on consideration of workspace geometry
# 2. join fullscreen related:
#   a) fullscreen window will be put to the workspace with ID 1 larger.
#   b) all windows reside in workspace ID larger than current workspace ID 
#      will be shifted towards workspace with larger ID.
#   c) if current workspace (except workspace 0) has only one window,
#      fullscreen is performed in current workspace.
# 3. exit fullscreen related:
#   a) fullscreen window seek a workspace with largest ID 
#      smaller than current workspace ID that has no fullscreen windows. 
#      Move the window to the founded workspace and delete current workspace.
#   b) If fullscreen window is in workspace 0, exit fullscreen without extra operations.
#   c) If workspace has other windows, exit fullscreen without extra operations.
#      If most fullscreen window is managed by this script, c) should be a rare case


dependency_check() {
	if [[ ! -f $(which wmctrl) || ! -f $(which xdotool) || ! -f $(which xprop) ]]
	then
		exit
	fi
}

# $1 current number of workspace
ins_workspace_tail() {
	wmctrl -n $(($1 + 1))
}

# $1 current number of workspace
del_workspace_tail() {
	wmctrl -n $(($1 - 1))
}

# sometimes fullscreen window is put behind taskbar panel
# so wait a bit and then activate window
# $1 is window id
activate_window() {
	sleep 0.01
	xdotool windowactivate $1
}

# shifting windows in a range of workspace
# $1 is lowerbound of workspace ID
# $2 is shift direction:
#     0: towards larger ID
#     1: towards smaller ID
# $3 number of workspace
shift_windows() {
	local lowbound=$1
	local direction=$2
	local num_workspace=$3
	# prepare id array in increasing or decreasing order
	local ids=()
	if [ $direction -eq "0" ]; then
		for (( id=$num_workspace-2 ; id >= $lowbound ; id-- )); do
			ids+=($id)
		done
	else
		for (( id=$lowbound+1 ; id < $num_workspace ; id++ )); do
			ids+=($id)
		done
	fi
	
	for id in ${ids[@]}; do
		if [ $direction -eq "0" ]; then
			local newid=$(( $id + 1 ))
		else
			local newid=$(( $id - 1 ))
		fi

		# $1 of awk is window id
		# $2 of awk is workspace id
		wmctrl -l | awk -v id=$id -v newid=$newid					\
			'/\-?[:hex:]+/{								\
				if ($2 == id)							\
					printf "wmctrl -ir %s -t %d\n", $1, newid | "/bin/sh"	\
			} 									\
			END {									\
				close("/bin/sh")						\
			}'
	done
}

# $1 is lowerbound of workspace ID
# caller guarantee $1 is larger than 0
ins_workspace() {
	# get workspace count and manually add it first
	# since wmctrl used in ins_workspace_tail is non-blocking ?
	# also less amount of query with wmctrl
	local num_workspace=$(wmctrl -d | wc -l)
	local new_num_workspace=$(($num_workspace + 1))
	ins_workspace_tail $num_workspace

	if (( $1 < $num_workspace )); then
		shift_windows $1 0 $new_num_workspace
	fi
}

# $1 is lowerbound of workspace ID
# caller guarantee $1 is larger than 0
del_workspace() {
	local num_workspace=$(wmctrl -d | wc -l)
	if (( $1 < $num_workspace )); then
		shift_windows $1 1 $num_workspace
	fi

	del_workspace_tail $num_workspace
}

# $1 is window ID
# caller use $? to test
#     0: not full screen window
#     1: full screen window
is_fullscreen() {
	local full="$(xprop -id $1 | grep '_NET_WM_STATE(ATOM)' \
				   | grep '_NET_WM_STATE_FULLSCREEN')"

	if [[ -n "$full" ]]; then
		return 1
	else
		return 0
	fi
}

# $1 is window ID
# caller guarantee $1 window is not fullscreen
join_fullscreen() {
	# $1 of awk is window id
	# $2 of awk is workspace id
	local workspace=$(wmctrl -l | awk -v id=$1 '/\-?[:hex:]+/{ if ($1 == id) print $2 }')
	local new_workspace=$(( $workspace + 1 ))
	local win_in_workspace=$(wmctrl -l \
		| awk -v id=$workspace '/\-?[:hex:]+/{ if ($2 == id) print $2 }' | wc -l)

	if [ "$workspace" == "-1" ]; then
		exit
	fi

	if (( workspace != 0 )) && (( win_in_workspace == 1 )); then
		wmctrl -ir $1 -b add,fullscreen
	else
		ins_workspace $new_workspace
		wmctrl -ir $1 -b add,fullscreen
		wmctrl -ir $1 -t $new_workspace
		wmctrl -s $new_workspace
	fi

	activate_window $1
}

# $1 is window ID
# caller guarantee $1 window is fullscreen
exit_fullscreen() {
	# $1 of awk is window id
	# $2 of awk is workspace id
	local workspace=$(wmctrl -l | awk -v id=$1 '/\-?[:hex:]+/{ if ($1 == id) print $2 }')
	local new_workspace=$(( $workspace - 1 ))
	local win_in_workspace=$(wmctrl -l \
		| awk -v id=$workspace '/\-?[:hex:]+/{ if ($2 == id) print $2 }' | wc -l)

	if [ "$workspace" == "-1" ]; then
		exit
	fi

	if (( $workspace == 0 )) || (( $win_in_workspace > 1 )); then
		wmctrl -ir $1 -b remove,fullscreen
		activate_window $1
		exit
	fi

	# find the workspace with largest ID 
	# smaller than specified window that has no fullscreen window
	while (( $new_workspace > 0 )); do
		local no_fullscreen=TRUE
		win_in_workspace=$(wmctrl -l \
			| awk -v id=$new_workspace '/\-?[:hex:]+/{ if ($2 == id) print $1 }')

		readarray -t win_array <<< "$win_in_workspace"
		for win in ${win_array[@]}; do
			is_fullscreen $win
			if (( $? == 1 )); then
				no_fullscreen=FALSE
				break;
			fi;
		done

		if [ "$no_fullscreen" == "TRUE" ]; then
			break;
		fi
		new_workspace=$(( $new_workspace - 1 ))
	done

	# at this point, current workspace only the fullscreen window
	# at workspace is not 0
	wmctrl -ir $1 -b remove,fullscreen
	wmctrl -ir $1 -t $new_workspace
	wmctrl -s $new_workspace
	del_workspace $workspace

	activate_window $1
}

main() {
	dependency_check

	WINDOW_ID=$(printf 0x%08x $(xdotool getactivewindow))
	is_fullscreen $WINDOW_ID
	if (( $? == 1 )); then
		exit_fullscreen $WINDOW_ID
	else
		join_fullscreen $WINDOW_ID
	fi
}

main
exit 0
