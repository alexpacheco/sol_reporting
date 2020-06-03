#!/bin/bash

pi=$1
if [[ -z "$2" ]]
then
  startday=1
else
  startday="$2"
fi

if [[ -z $3 ]]
then
  endday=1
else
  endday=$3
fi



start=$(date -d "$startday day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$endday day ago" +%Y-%m-%d-23:59:59)

dailysu=$(sinfo -N --Format=cpus -p lts,im1080,eng,engc,enge,himem-long,engi,im2080 | awk '{s+=$1}END{print s*24}')
ay=1920
ayold=1819

difftime=86400

numdays=$(( $startday - $endday ))
if [[ $numdays == 0 ]] ; then numdays=1 ; fi

echo "Usage report "
echo "Account: $pi" 
echo "Start: $start" 
echo "End  : $end"

echo "==============================="
usage=$(sacct -a -A ${pi}_${ay},${pi}_{ayold} --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW -n | \
  awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{if( $1 == "himem"){s+=$NF*3}else{s+=$NF}}}END{print s/60/60,NR}')
#echo $pi $usage $dailysu $numdays | awk '{printf " %6s: %12.2f %8.2f%\n",$1,$2,$2/($3*$4)*100}'
echo $usage | awk '{printf "%14s %12.2f\n%14s %9d\n","SUs consumed: ",$1,"# Jobs Ran: ", $2}'
echo "==============================="
echo "   User:     SUs Usage    #Jobs"
echo "==============================="

for user in $(sshare -a -A ${pi}_${ay} -o User | tail -n +3 | sort | uniq )
do
  usage=$(sacct -A ${pi}_${ay},${pi}_{ayold} -u $user --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X \
    -o Partition,CPUTimeRAW -n | \
    awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{if( $1 == "himem"){s+=$NF*3}else{s+=$NF}}}END{print s/60/60,NR}')
  echo $user $usage | awk '{printf " %6s: %12.2f  %8d\n",$1,$2,$3}'
done
echo "==============================="
echo 
echo "Total Allocation Used"
/home/alp514/bin/pireport -p $pi 
echo 

