#!/bin/bash

#$1 - sql
#$2 - threads
#$3 - retries

echo "type db name"
read dbname
echo "type db owner username"
read dbuser
echo "type pass word"
read dbpass
passwd="testmysql"

#/etc/init.d/mysql stop
#/etc/init.d/mysql start || exit 1
#pkill phase


echo -n > status

countwc="`cat status | grep complete | wc -l`"
#count=$(( ${countwc}*$2 ))
#echo ${1}.timed

./phase_two.sh $1 $2 $3 $dbpass $dbuser $dbname &

aa="0"
time1="`date +%s`"

while [[ "$countwc" -lt "$2" ]]; do

    wclout="`cat ${1}.out.0 | wc -l`"
    wclin="`cat $1 | wc -l`"
    time2="`date +%s`"
    timework=$(($time2-$time1))
    timeworkmin="`echo "scale=2; $timework/60" | bc`"
    [ "$wclout" == "0" ] || speed="`echo "scale=5; $timework/$wclout" | bc`"
    [ "$wclout" == "0" ] && speed=$timework
    estline="`echo "scale=5; ${wclin}-$wclout" | bc`"
    estmin="`echo "scale=2; ($speed*$estline)/60" | bc`"
    #echo "$wclin $wclout $speed $estline $timework"
    mysqlthreads="`mysql -u$dbuser -p$dbpass $dbname -e "show status ;" | grep Threads_connected | awk '{ print $2 }'`"
    echo "`date +%H:%M:%S-%d.%m.%Y` : mysql $mysqlthreads : phase `pgrep -fl phase | wc -l` : $wclout из $estline строк обработали : $timeworkmin из $estmin мин отработали" | tee -a status
    
    #echo "$wclout строк обработано"
    #est="`echo "0.011*$(( $wclin*20-$wclout ))" | bc`"
    #echo "$est минут осталось"
    #echo "`echo "scale=5; 100/($wclin*20)*$wclout" | bc` % обработано"

    countwc="`cat status | grep complete | wc -l`"
    sleep 10
done
    uptime=$(( `date +%s` - $time1))
    echo "uptime $uptime"
    echo "uptime $uptime" >> status
    mysql -u$dbuser -p$dbpass $dbname -e "show status;" > mysql.status
    mysql -u$dbuser -p$dbpass $dbname -e "show variables;" > mysql.variables
#/etc/init.d/mysql stop
    echo "concatenate ..."
    echo -n > $1.out.$2.count
    echo -n > $1.out.$2.time
    echo -n > $1.out.$2.query

for (( i=0 ; i<$2 ; i++)); do
    cat $1.out.$i >> $1.out.$2.count
done
    echo "sort ..."
    cat "$1.out.$2.count" | awk -F: '{ print $2,":",$1,":",$3 }' > $1.out.$2.time
    cat "$1.out.$2.count" | awk -F: '{ print $3,":",$1,":",$2 }' > $1.out.$2.query

    sort -n -o "$1.out.$2.count.sort" "$1.out.$2.count"
    sort -n -o "$1.out.$2.time.sort" "$1.out.$2.time"
    sort -n -o "$1.out.$2.query.sort" "$1.out.$2.query"
    

    echo complete
    pkill phase