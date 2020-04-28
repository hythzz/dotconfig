#!/bin/bash

# variables
SSH_PORT=22
LOCAL_PORT=
REMOTE_PORT=
USER=
HOSTNAME=

usage () {
	echo ""
	echo "Usage: secure_vnc.sh <OPTION>"
	echo ""
	echo "       -p <ssh_port>      [optional] ssh tunnel port number"
	echo "                          default to 22"
	echo "       -l <local_port>    port for local traffic forwarding"
	echo "       -x <X display #>   vnc server X display number"
	echo "                          vnc server port will be 5900 + X display #"
	echo "       -u <user name>     ssh tunnel user name"
	echo "       -n <host name>     vnc server host name"
	echo ""
}

check () {
	VALID=true
	if [ -z "$LOCAL_PORT" ]; then
		echo "localhost forwarding port not specified"
		VALID=false
	fi
	if [ -z "$REMOTE_PORT" ]; then
		echo "remote vnc server port not specified"
		VALID=false
	fi
	if [ -z "$USER" ]; then
		echo "user not specified"
		VALID=false
	fi
	if [ -z "$HOSTNAME" ]; then
		echo "hostname not specified"
		VALID=false
	fi
	if [ $VALID == "false" ]; then
		usage
		exit -1
	fi
}

opts='p:l:x:u:n:h'
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts $opts option
do
    case "$option" in
        p  ) SSH_PORT=$OPTARG;;
        l  ) LOCAL_PORT=$OPTARG;;
        x  ) REMOTE_PORT=$((5900 + $OPTARG));;
        u  ) USER=$OPTARG;;
        n  ) HOSTNAME=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    esac
done
check;

CMD="ssh -p $SSH_PORT -C -L $LOCAL_PORT:localhost:$REMOTE_PORT $USER@$HOSTNAME"
echo "Host Name:     $HOSTNAME"
echo "User Name:     $USER"
echo "SSH Port:      $SSH_PORT"
echo "Local Port:    $LOCAL_PORT"
echo "Remote Port:   $REMOTE_PORT"
echo "CMD:           $CMD"
echo ""

$CMD
