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

exit


start=$(date -d "$startday week ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$endday week ago" +%Y-%m-%d-23:59:59)

dailysu=$(sinfo -l -N --Format=cpus -p lts,imlab | awk '{s+=$1}END{print s*24}')

difftime=86400

numdays=$(( $startday - $endday ))
if [[ $numdays == 0 ]] ; then numdays=1 ; fi

echo "Usage report "
echo "PI: $pi" 
echo "Start Date and Time : $start" 
echo "End Date and Time: $end"

echo "====================="
usage=$(sacct -a -A $pi --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
  awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{s+=$NF}}END{print s/60/60}')
#echo $pi $usage $dailysu $numdays | awk '{printf " %6s: %12.2f %8.2f%\n",$1,$2,$2/($3*$4)*100}'
echo $pi $usage | awk '{printf " %6s: %12.2f\n",$1,$2}'
echo "====================="

for user in $(sshare -a -A $pi -o User | tail -n +3 | sort | uniq )
do
  usage=$(sacct -A $pi -u $user --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X \
    -o Partition,CPUTimeRAW | \
    awk '{if ( $2 ~ /bio-s/){s+=$NF/24}else{s+=$NF}}END{print s/60/60}')
  echo $user $usage | awk '{printf " %6s: %12.2f\n",$1,$2}'
done
echo 
echo "Total Allocation Used"
solreport -a -p $pi | cut -c 9-
echo 

