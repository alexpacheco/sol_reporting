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

state="COMPLETED,CANCELLED,FAILED,TIMEOUT,PREEMPTED,NODE_FAIL,OUT_OF_MEMORY"
start=$(date -d "$first day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$third day ago" +%Y-%m-%d-23:59:59)

cores=$(sinfo -N --Format=cpus -p lts,im1080,eng,engc | awk '{s+=$1}END{print s}')
dailysu=$(sinfo -N --Format=cpus -p lts,im1080,eng,engc | awk '{s+=$1}END{print s*24}')
ltssu=$(sinfo -N --Format=cpus -p lts | awk '{s+=$1}END{print s*24}')
engsu=$(sinfo -N --Format=cpus -p eng | awk '{s+=$1}END{print s*24}')
im1080su=$(sinfo -N --Format=cpus -p im1080 | awk '{s+=$1}END{print s*24}')
im2080su=$(sinfo -N --Format=cpus -p im2080 | awk '{s+=$1}END{print s*24}')
hawkgpusu=$(sinfo -N --Format=cpus -p hawkgpu | awk '{s+=$1}END{print s*24}')
piscessu=$(sinfo -N --Format=cpus -p pisces | awk '{s+=$1}END{print s*24}')
ima40su=$(sinfo -N --Format=cpus -p ima40-gpu | awk '{s+=$1}END{print s*24}')

# im1080 : 2017-01-19
# eng-gpu : 2017-12-01
# im2080-gpu : 2019-01-02 
# lts-gpu : 2020-03-20
# hawkgpu: 2020-11-12
# pisces: 

year=$(date -d "$day day ago" +%Y)
month=$(date -d "$day day ago" +%m)
mday=$(date -d "$day day ago" +%d) 

date -d "$third day ago" +"%Y/%m/%d" | awk '{printf " %12s",$1}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r imlab-gpu,im1080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$im1080su'*100}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r eng-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$engsu'*100}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r im2080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$im2080su'*100}' >> $DIR/dailygpu.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r lts-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$ltssu'*100}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r hawkgpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$hawkgpusu'*100}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r pisces,pisces-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$piscessu'*100}' >> $DIR/dailygpu.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r ima40-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f\n",cur,cur/'$ima40su'*100}' >> $DIR/dailygpu.dat

tail -1 $DIR/dailygpu.dat | sed -e 's_/_-_g' | awk '{printf "%s %s",$1,"00:00:00 EST,"}{for (i=2;i<NF;i++){printf "%s,",$i}printf "%s\n",$NF}' >> $DIR/dailygpu.csv

