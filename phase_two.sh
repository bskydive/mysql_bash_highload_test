#!/bin/bash

filein=$1
threads=$2
retries=$3
dbpass=$4
dbuser=$5
dbname=$6

#todo
#collect all output to log
#echo end process

#(( thread_buffer=${threads} ))

#nthread=1
#exec 119<> "$filein"

echo "prepare copies ..."

for (( i=0 ; i<$threads ; i++ )); do    
    #echo "out `wc -l $fileout` : thread_buffer $thread_buffer : nthread $nthread : "
    #[ "`cat $fileout | wc -l`" -eq $thread_buffer ] && (( thread_buffer=$thread_buffer+${threads} ))
    #j="`cat $filein | awk -F: '{ print $2 }'`"

    fileout="${filein}.${i}.in"
    cp -f "$filein" "${fileout}"
    echo -n > "${fileout}".tmp
    echo -n > "${fileout}".tmp1
    echo -n > "${filein}.out.$i"
    echo -n > "${filein}.out.$i.err"

    while read ii; do
    rnumber=$RANDOM
    echo "$rnumber : $ii" >> "$fileout".tmp
    done<"$filein"

    sort -n -o "$fileout".tmp1 "$fileout".tmp 
    
    cat "$fileout".tmp1 | awk -F: '{ print $2, ":", $3 }'  > "$fileout"
    
done

echo "run threads ..."

for (( i=0 ; i<$threads ; i++ )); do    
#    descnum=$(( ${i}+110 ))
#    ./phase_three.sh "${filein}.${i}.in" "${filein}.out.$i" "${descnum}" "$retries" "$4" &
    ./phase_three.sh "${filein}.${i}.in" "${filein}.out.$i" "${retries}" "${dbpass}" "${dbuser}" "${dbname}" &
    echo "${filein}.${i}.in ${filein}.out.$i ${descnum}  start"
done

