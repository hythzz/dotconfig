#!/bin/bash
CMD="sudo -E hardcode-tray --conversion-tool RSVGConvert --size 22 --theme Papirus"

if [[ ! -t 1 ]]; then
	echo -e "this script should be run in terminal directly"
fi

echo "Command going to run: "
echo $CMD
printf "!! this script need to run in root (Y/n): "
read INPUT
if [ $INPUT != "Y" ]; then
	exit -1
fi

$CMD
