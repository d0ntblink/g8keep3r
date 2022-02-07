#!/bin/bash

print_help () {
    echo "Correct Usage:"
    echo "  g8keepr --add <username>"
    echo "  g8keepr --remove <username>"
    exit 14
}

print_error () {
    echo "unknown argument please try again"
    exit 15
}

removing_proc () {
    username="$1"
    echo "removing $username from the watched list"
}

adding_proc () {
    if  [ `grep -Fxq "$username" ./watch.list 2>/dev/null` ] ; then
        echo "this username is already being watched for"
        echo "to remove a user from the watchlist please use --remove <username>"
        exit 15
    else
        username="$1"
        watchdog_cronfile="$username.g8keepr.parser.schedule"
        echo "$username" >> ./watch.list
        echo "watching $username"
        # (crontab -l; echo "* * * * * `pwd`/parser.sh $username # g8keepr for $username") | awk '!x[$0]++' |crontab -
        echo "*  *  *  *  *    root    `pwd`/parser.sh $username" >> /etc/crontab
    fi
}

if [[ $EUID -gt 0 ]]; then
    echo "This script must be run as root"
    exit 12
fi

if [[ $# -lt 2 ]]; then
    echo "this script requires a username as an argument"
    echo "use --help to display this message"
    echo "Correct Usage:"
    echo "  g8keepr --add <username>"
    echo "  g8keepr --remove <username>"
    exit 13
fi

case "${1}" in
	"")         print_help;;
    --add)     adding_proc "$2";;
    --remove)     removing_proc "$2";;
    --help)   print_help;;
    *)          print_error;;
esac


# tail -n 100 /var/log/auth.log | awk '/password|sshd[*.]/{print $3,$11,$6,$9}' | awk '! /message/' | sed -e 's/sshd\[//g' -e 's/\]://g'