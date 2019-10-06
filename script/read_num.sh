#!/bin/bash
#i=1
#for x in $(grep -o '[0-9]\{1\}' a.txt);
#do
#    y[$i]=$x
#    echo ${y[i]}
#    ((i++))
#done

#cat a.txt | awk '{print $0}'
#cat a.txt | awk '{for(i=1;i<NF;i++) {print $i} }'

while read line
do
    i=1
    echo "${line}"
#    for x in $(echo "${line}" | grep -o '[0-9]\{1\}'):
#    do
#        y[$i]=$x
#        echo ${y[i]}
#        ((i++))
#    done
#    for x in $(echo ${line} | awk '{print $0}'):
#    do
#        y[$i]=$(echo "${x}" | grep -o '[0-9]\{1\}') # delete the : in the last num
#        let b=y[$i]-1
#        echo "b =$b"
#        echo ${y[i]}
#        ((i++))
#    done
    IFS=" "
    arr=(${line})
    for num in ${arr[@]}
    do
        echo $num
    done

done < imu_parameters_array.txt
#(sum=${y[1]}+${y[2]}+${y[3]}+${y[4]})
#echo $sum