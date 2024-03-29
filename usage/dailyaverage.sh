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

cores=$(sinfo -N --Format=cpus -p lts,imlab,eng,engc,imlab,himem,enge,engi,im1080,im2080,chem,health,hawkcpu,hawkmem,hawkgpu,infolab,pisces,ima40-gpu | awk '{s+=$1}END{print s}')
dailysu=$(sinfo -N --Format=cpus -p lts,imlab,eng,engc,imlab,himem,enge,engi,im1080,im2080,chem,health,hawkcpu,hawkmem,hawkgpu,infolab,pisces,ima40-gpu | awk '{s+=$1}END{print s*24}')
ltssu=$(sinfo -N --Format=cpus -p lts | awk '{s+=$1}END{print s*24}')
im1080su=$(sinfo -N --Format=cpus -p imlab,imlab-hold,im1080 | awk '{s+=$1}END{print s*24}')
engsu=$(sinfo -N --Format=cpus -p eng | awk '{s+=$1}END{print s*24}')
engcsu=$(sinfo -N --Format=cpus -p engc | awk '{s+=$1}END{print s*24}')
himemsu=$(sinfo -N --Format=cpus -p himem-long | awk '{s+=$1}END{print s*24}')
engesu=$(sinfo -N --Format=cpus -p enge | awk '{s+=$1}END{print s*24}')
engisu=$(sinfo -N --Format=cpus -p engi | awk '{s+=$1}END{print s*24}')
im2080su=$(sinfo -N --Format=cpus -p im2080 | awk '{s+=$1}END{print s*24}')
chemsu=$(sinfo -N --Format=cpus -p chem | awk '{s+=$1}END{print s*24}')
healthsu=$(sinfo -N --Format=cpus -p health | awk '{s+=$1}END{print s*24}')
hawkcpusu=$(sinfo -N --Format=cpus -p hawkcpu | awk '{s+=$1}END{print s*24}')
hawkmemsu=$(sinfo -N --Format=cpus -p hawkmem | awk '{s+=$1}END{print s*24}')
hawkgpusu=$(sinfo -N --Format=cpus -p hawkgpu | awk '{s+=$1}END{print s*24}')
infolabsu=$(sinfo -N --Format=cpus -p infolab | awk '{s+=$1}END{print s*24}')
piscessu=$(sinfo -N --Format=cpus -p pisces | awk '{s+=$1}END{print s*24}')
ima40su=$(sinfo -N --Format=cpus -p ima40-gpu | awk '{s+=$1}END{print s*24}')


year=$(date -d "$day day ago" +%Y)
month=$(date -d "$day day ago" +%m)
mday=$(date -d "$day day ago" +%d) 

if [[ "$mday" == "01" ]]; then
  echo "$(date -d "$day day ago" +%b)" | awk '{printf " %12s\n",$1}' >> $DIR/$year-$month.daily
fi

echo $mday | awk '{printf "%4d  ",$1}' >> $DIR/$year-$month.daily
date -d "$third day ago" +"%Y/%m/%d" | awk '{printf " %12s",$1}' >> $DIR/daily.dat

sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$dailysu'*100}' >> $DIR/daily.dat
#	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$dailysu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r lts,lts-gpu -X -o CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$ltssu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r imlab,imlab-gpu,bio,bio-s,imlab-hold,imlab-long,imlab-emergency,im1080,im1080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$im1080su'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r eng,eng-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$engsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r engc,engc-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$engcsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r all-cpu,all-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$dailysu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r himem,himem-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$himemsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r enge,enge-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$engesu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r engi,engi-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$engisu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r im2080,im2080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$im2080su'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r chem,chem-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$chemsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r health -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$healthsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r hawkcpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$hawkcpusu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r hawkmem -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$hawkmemsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r hawkgpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$hawkgpusu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r infolab -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$infolabsu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r pisces,pisces-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f",cur,cur/'$piscessu'*100}' >> $DIR/daily.dat
sacct -a --state=$state \
	--starttime=$(date -d "$third day ago" +%Y-%m-%d-00:00:00) \
	--endtime=$(date -d "$third day ago" +%Y-%m-%d-23:59:59) \
	-r ima40-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "%11.2f  %9.2f\n",cur,cur/'$ima40su'*100}' >> $DIR/daily.dat

tail -1 daily.dat | sed -e 's_/_-_g' | awk '{printf "%s %s",$1,"00:00:00 EST,"}{for (i=2;i<NF;i++){printf "%s,",$i}printf "%s\n",$NF}' >> daily.csv

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$dailysu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r lts,lts-gpu -X -o CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$ltssu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r imlab,imlab-gpu,bio,bio-s,imlab-hold,imlab-long,imlab-emergency,im1080,im1080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$im1080su'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r eng,eng-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$engsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r engc,engc-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$engcsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r all-cpu,all-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$dailysu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r himem,himem-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$himemsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r enge,enge-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$engesu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r engi,engi-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$engisu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r im2080,im2080-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$im2080su'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r chem,chem-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$chemsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r health -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$healthsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r hawkcpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$hawkcpusu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r hawkmem -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$hawkmemsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r hawkgpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$hawkgpusu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r infolab -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$infolabsu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r pisces,pisces-long -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f",cur,cur/'$piscessu'*100}' >> $DIR/$year-$month.daily

sacct -a --state=$state \
	--starttime=$start \
	--endtime=$end \
	-r ima40-gpu -X -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60/3;printf "%11.2f  %9.2f\n",cur,cur/'$ima40su'*100}' >> $DIR/$year-$month.daily

git add $DIR/$year-$month.daily daily.dat daily.csv

