#!/usr/bin/bash


# date format : Feb 6 19:11:45
# line format : Feb 6 02:52:49 10.0.0.228

username="$1"
tmpfile="./tmp.$username.data.tmp"
watchdogfile="./$username.data"
declare -i datern=$(date +%s)
declare -A maliciousips=()

awk -v username="$username" '
{
    if($9==username)
    {
        if($6=="Failed")
        {
            print $1,$2,$3,$11;
        }
        if($6=="Accepted")
        {
            system("echo -n > " username".data.tmp")
        }
    }
}
' "./auth.log" > $tmpfile

while read line; do
    linedate=$(echo $line | awk '{print $1,$2,$3}') && linedate=$(date -d "$linedate" +%s)
    ip=$(echo $line | awk '{print $4}') 
    declare -i intlinedate=$linedate
    if [ $(expr $datern - $intlinedate) -gt 60 ]; then
        maliciousips[$ip]+=x
    fi
done < $tmpfile

for key in "${!maliciousips[@]}"; do
    if [[ $(echo -n "${maliciousips[$key]}" | wc -m) -gt 3 ]]; then
        echo -n "$ip got timedout for 10 minutes " >> $watchdogfile
        echo "on `date`" >> $watchdogfile
        # this is were we pass $ip to the iptables script
    fi
done

rm -rf $tmpfile