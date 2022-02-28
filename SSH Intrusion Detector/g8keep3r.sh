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
    if  grep -q "$username" $g8dir/watch.list 2>/dev/null; then
        echo "removing $username from the watched list"
        crontab -u root -l 2>/dev/null; grep -v "$username" | crontab -u root -
    else
        echo "$username was not being watched"
        exit 17
    fi
}

adding_proc () {
    username="$1"
    attempts="$2"
    duration="$3"
    if  grep -q "$username" $g8dir/watch.list 2>/dev/null; then
        echo "this username is already being watched for"
        echo "to remove a user from the watchlist please use --remove <username>"
        exit 16
    else
        # watchdog_cronfile="$username.g8keepr.parser.schedule"
        echo "$username" >> $g8dir/watch.list
        echo "watching $username for $attempts failed attempts. timeout duration is $duration"
        crontab -u root -l 2>/dev/null; echo "* * * * * sudo -u root bash $g8dir/parser.sh $username $attempts $duration" | crontab -u root -
        # echo "*  *  *  *  *    root    `pwd`/parser.sh $username" >> /etc/crontab
    fi
}

g8dir="$(dirname "$(readlink -f "$0")")"

if [[ $EUID -gt 0 ]]; then
    echo "This script must be run as root"
    exit 12
fi

( iptables -V >/dev/null ) || ( echo "iptables is missing" && exit 16)
( sudo -u root ipset -v >/dev/null ) || ( echo "ipset is missing, install it and try again" && exit 16)
sudo -u root ipset create g8keep3r hash:ip timeout 0 2>/dev/null
# ipset create test hash:ip timeout 300
( sudo -u root iptables -L 2>/dev/null | grep g8keep3r ) || sudo -u root iptables -I INPUT -m set --match-set g8keep3r src -j DROP

if [[ $# -lt 2 ]]; then
    echo "this script requires a username as an argument"
    echo "use --help to display this message"
    echo "Correct Usage:"
    echo "  g8keepr --add <username> <maximum failed attempts in 1 minute allowed> <timeout durations in seconds>"
    echo "  g8keepr --remove <username>"
    exit 13
fi

case "${1}" in
	"")         print_help;;
    --add)     adding_proc "$2 $3 $4";;
    --remove)     removing_proc "$2";;
    --help)   print_help;;
    *)          print_error;;
esac


# tail -n 100 /var/log/auth.log | awk '/password|sshd[*.]/{print $3,$11,$6,$9}' | awk '! /message/' | sed -e 's/sshd\[//g' -e 's/\]://g'
