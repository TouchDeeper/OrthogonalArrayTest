#!/bin/sh

i=1
SUM=`sed -n '$=' data/L64_4_21.txt` #计算文件的总行数
echo "$SUM"

exit 1
#echo "$i"
#i=1
#for i in `seq $SUM` ;do 
#    echo "${arr[$i]}"
#done
