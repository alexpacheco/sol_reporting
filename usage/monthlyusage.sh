#!/bin/bash

accounts=$(sshare -o Account,RawUsage,GrpTRESMins | egrep -i 1920 | awk -F_ '{print $1}')

for pi in $accounts
do 
  solreport -p $pi -m 1 > $pi.txt
done

start=$(date -d "1 month ago" +%Y-%m-01-00:00:00)
end=$(date -d "0 month ago" +%Y-%m-01-00:00:00)
echo $start $end

for pi in $accounts lts 
do
  echo $pi | awk '{printf "%10s",$1}' 
  sacct -a -A $pi,${pi}_1819 --starttime=$start --endtime=$end -X --state=COMPLETED,CANCELLED,FAILED,TIMEOUT -o CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "  %9.2f\n",cur}'
done
