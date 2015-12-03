#!/bin/bash

#$1 - filein
#$2 - fileout
#$3 - descnum
#$4 - retry
#$5 - passwd

filein=$1
fileout=$2
retry=$3
dbpass=$4
dbuser=$5
dbname=$6

echo "filein=$filein fileout=$fileout $retry $dbpass"

#read filein by strings
while read ii;do

number="`echo $ii | awk -F: '{ print $1 }'`"
sqlstr="`echo $ii | awk -F: '{ print $2 }'`"
#delay="`/usr/bin/time -f "times %e" mysql -u$dbowner -p$dbpass $dbname  -e "$sqlstr" | grep -E "^times"`"
time1="`date +%s`"

for (( k=1 ; k<"$retry" ; k++)); do
echo "$sqlstr" | mysql -u$dbuser -p$dbpass --default-character-set=utf8 $dbname 1>/dev/null 2>>"$fileout.err" || echo "`date +%H:%M:%S-%d.%m.%Y` : $? " >> "$fileout.err"
done

time2="`date +%s`"
delay=$(( time2-time1  ))

echo "$number : $delay : $sqlstr" >> "$fileout"

done<"$filein"

teea="`date +%H:%M:%S-%d.%m.%Y` : complete $fileout" 
echo $teea
echo $teea >> status





