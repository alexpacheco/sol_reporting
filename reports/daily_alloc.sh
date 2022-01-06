#!/bin/bash

pi=$1
if [[ -z "$2" ]]
then
  start=$(date -d "today" +%Y-%m-%d-00:00:00)
else
  start=$(date -d "$2 day ago" +%Y-%m-%d-00:00:00)
#echo $2 | awk '{printf "%s",$1"-00:00:00"}')
fi

if [[ -z $3 ]]
then
  end=$(date -d "today" +%Y-%m-%d-23:59:59)
else
  end=$(date -d "$3 day ago" +%Y-%m-%d-23:59:59)
#echo $3 | awk '{printf "%s",$1"-23:59:59"}')
fi



dailysu=$(sinfo -N --Format=cpus -p lts,im1080,eng,engc,enge,himem-long,engi,im2080 | awk '{s+=$1}END{print s*24}')

difftime=86400


echo "Usage report "
echo "Account: $pi" 
echo "Start: $start" 
echo "End  : $end"

echo "==============================="
usage=$(sacct -a -A ${pi} --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW -n | \
  awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{if( $1 == "himem"){s+=$NF*3}else{s+=$NF}}}END{print s/60/60,NR}')
#echo $pi $usage $dailysu $numdays | awk '{printf " %6s: %12.2f %8.2f%\n",$1,$2,$2/($3*$4)*100}'
echo $usage | awk '{printf "%14s %12.2f\n%14s %9d\n","SUs consumed: ",$1,"# Jobs Ran: ", $2}'
echo "==============================="
echo "   User:     SUs Usage    #Jobs"
echo "==============================="

for user in $(sshare -a -A ${pi} -o User | tail -n +3 | sort | uniq )
do
  usage=$(sacct -A ${pi} -u $user --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X \
    -o Partition,CPUTimeRAW -n | \
    awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{if( $1 == "himem"){s+=$NF*3}else{s+=$NF}}}END{print s/60/60,NR}')
  echo $user $usage | awk '{printf " %6s: %12.2f  %8d\n",$1,$2,$3}'
done
echo "==============================="
echo 
echo "Total Allocation Used"
/home/alp514/bin/pireport.old -p $pi -s $start -e $end 
echo 

