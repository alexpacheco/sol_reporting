#!/bin/bash


if [[ -z "$1" ]]
then
  day=1
else
  day="$1"
fi

start=$(date -d "$day day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$day day ago" +%Y-%m-%d-23:59:59)

DATE=$(date -d "$day day ago" +%Y/%m/%d)

difftime=86400

pi=$2
  echo $DATE | awk '{printf " %10s ",$1}' >> userstats/$pi.dat
  sacct -a -A $pi,${pi}_1718 --starttime=$start --endtime=$end -X --state=COMPLETED,CANCELLED,FAILED,TIMEOUT -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "  %9.2f\n",cur}' >> userstats/$pi.dat
  totalusage=$(sacct -a -A $pi \
	--starttime=2016-10-01-00:00:00 \
	--endtime=$end \
	-X --state=COMPLETED,CANCELLED,FAILED,TIMEOUT -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "  %9.2f\n",cur}')

