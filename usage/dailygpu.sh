#!/bin/bash


DIR=/home/alp514/usage
if [[ -z "$1" ]]
then
  day=2
else
  day="$1"
fi

let first=$day+1
let third=$day-1

state="COMPLETED,CANCELLED,FAILED,TIMEOUT"
start=$(date -d "$first day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$third day ago" +%Y-%m-%d-23:59:59)

cores=$(sinfo -N --Format=cpus -p lts,imlab,eng,engc | awk '{s+=$1}END{print s}')
dailysu=$(sinfo -N --Format=cpus -p lts,imlab,eng,engc | awk '{s+=$1}END{print s*24}')
ltssu=$(sinfo -N --Format=cpus -p lts | awk '{s+=$1}END{print s*24}')
biosu=$(sinfo -N --Format=cpus -p imlab | awk '{s+=$1}END{print s*24}')
engsu=$(sinfo -N --Format=cpus -p eng | awk '{s+=$1}END{print s*24}')
engcsu=$(sinfo -N --Format=cpus -p engc | awk '{s+=$1}END{print s*24}')
gpusu=$(sinfo -N --Format=nodes -p imlab-gpu | awk '{s+=$1}END{print s*2*24}')


year=$(date -d "$day day ago" +%Y)
month=$(date -d "$day day ago" +%m)
mday=$(date -d "$day day ago" +%d) 

date -d "$third day ago" +"%Y/%m/%d" | awk '{printf " %12s",$1}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r imlab-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f\n",cur,cur/'$gpusu'*100}' >> $DIR/dailygpu.dat


