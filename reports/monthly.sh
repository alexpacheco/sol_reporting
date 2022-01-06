#!/bin/bash

if [[ -z "$1" ]]
then
  prevmonth=1
  thismonth=0
else
  prevmonth="$1"
  let thismonth=$prevmonth-1
fi

ay=1920
ayold=1819

start=$(date -d "$prevmonth month ago" +%Y-%m-01-00:00:00)
end=$(date -d "$thismonth month ago" +%Y-%m-01-00:00:00)

numdays=$(cal $(date -d "$prevmonth month ago" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')

#totalalloc=$(echo $numdays | awk '{print $1*24*(780+192)}')
ltscore=$(sinfo -N --Format=cpus -p lts | awk '{s+=$1}END{print s}')
im1080core=$(sinfo -N --Format=cpus -p im1080 | awk '{s+=$1}END{print s}')
engcore=$(sinfo -N --Format=cpus -p eng | awk '{s+=$1}END{print s}')
engccore=$(sinfo -N --Format=cpus -p engc | awk '{s+=$1}END{print s}')
himemcore=$(sinfo -N --Format=cpus -p himem-long | awk '{s+=$1}END{print s}')
engecore=$(sinfo -N --Format=cpus -p enge | awk '{s+=$1}END{print s}')
engicore=$(sinfo -N --Format=cpus -p engi | awk '{s+=$1}END{print s}')
im2080core=$(sinfo -N --Format=cpus -p im2080 | awk '{s+=$1}END{print s}')
chemcore=$(sinfo -N --Format=cpus -p chem | awk '{s+=$1}END{print s}')
healthcore=$(sinfo -N --Format=cpus -p health | awk '{s+=$1}END{print s}')
hawkcpucore=$(sinfo -N --Format=cpus -p hawkcpu | awk '{s+=$1}END{print s}')
hawkgpucore=$(sinfo -N --Format=cpus -p hawkgpu | awk '{s+=$1}END{print s}')
hawkmemcore=$(sinfo -N --Format=cpus -p hawkmem | awk '{s+=$1}END{print s}')
infolabcore=$(sinfo -N --Format=cpus -p infolab | awk '{s+=$1}END{print s}')
ltsalloc=$(echo $numdays $ltscore | awk '{print $1*$2*24}')
im1080alloc=$(echo $numdays $im1080core | awk '{print $1*$2*24}')
engalloc=$(echo $numdays $engcore | awk '{print $1*$2*24}')
engcalloc=$(echo $numdays $engccore | awk '{print $1*$2*24}')
himemalloc=$(echo $numdays $himemcore | awk '{print $1*$2*24}')
engealloc=$(echo $numdays $engecore | awk '{print $1*$2*24}')
engialloc=$(echo $numdays $engicore | awk '{print $1*$2*24}')
im2080alloc=$(echo $numdays $im2080core | awk '{print $1*$2*24}')
chemalloc=$(echo $numdays $chemcore | awk '{print $1*$2*24}')
healthalloc=$(echo $numdays $healthcore | awk '{print $1*$2*24}')
hawkcpualloc=$(echo $numdays $hawkcpucore | awk '{print $1*$2*24}')
hawkgpualloc=$(echo $numdays $hawkgpucore | awk '{print $1*$2*24}')
hawkmemalloc=$(echo $numdays $hawkmemcore | awk '{print $1*$2*24}')
infolaballoc=$(echo $numdays $infolabcore | awk '{print $1*$2*24}')
totalalloc=$(echo $ltsalloc $im1080alloc $engalloc $engcalloc $himemalloc $engealloc $engialloc $im2080alloc $chemalloc $healthalloc $hawkcpualloc $hawkgpualloc $hawkmemalloc $infolaballoc| awk '{for (i=1;i<=NF;i++){s+=$i}}END{print s}')
total=0

echo Monthly SUs
echo "lts    :" $ltsalloc
echo "im1080 :" $im1080alloc
echo "eng    :" $engalloc
echo "engc   :" $engcalloc
echo "himem  :" $himemalloc
echo "enge   :" $engealloc
echo "engi   :" $engialloc
echo "im2080 :" $im2080alloc
echo "chem   :" $chemalloc
echo "health :" $healthalloc
echo "hawkcpu:" $hawkcpualloc
echo "hawkgpu:" $hawkgpualloc
echo "hawkmem:" $hawkmemalloc
echo "infolab:" $infolaballoc
echo "total  :" $totalalloc

#echo $tic $tock $difftime

echo "Monthly Sol Usage: $(date -d "$prevmonth month ago" +"%B, %Y")"
echo "================================"
echo "  User        SUs used     % Use"
echo "================================"
for user in $(sacct -a --starttime=$start --endtime=$end -X -o User | tail -n +3 | sort | uniq )
do
  usage=$(sacct -u $user --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o CPUTimeRAW | awk '{s+=$NF}END{print s/60/60}')
  echo $user $usage $totalalloc| awk '{printf " %6s: %12.2f  %8.2f\n",$1,$2,$2/$3*100}'
  total=$(echo $total $usage | awk '{printf "%12.2f\n",$1+$2}')
done
echo "================================"
echo Total Monthly Usage: $total
usepercent=$(echo $total $totalalloc | awk '{printf "%8.2f\n",$1/$2*100}')
echo "% Usage:" $usepercent
echo "========================================"
echo "Usage by Partition"
sacct -r lts -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","lts",s/60/60,(s/60/60)/'$ltsalloc'*100}'
sacct -r im1080,im1080-gpu -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","im1080",s/60/60,(s/60/60)/'$im1080alloc'*100}'
sacct -r eng -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","eng",s/60/60,(s/60/60)/'$engalloc'*100}'
sacct -r engc -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","engc",s/60/60,(s/60/60)/'$engcalloc'*100}'
sacct -r himem,himem-long -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","himem",s/60/60,(s/60/60)/'$himemalloc'*100}'
sacct -r enge -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","enge",s/60/60,(s/60/60)/'$engealloc'*100}'
sacct -r engi -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","engi",s/60/60,(s/60/60)/'$engialloc'*100}'
sacct -r im2080,im2080-gpu -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","im2080",s/60/60,(s/60/60)/'$im2080alloc'*100}'
sacct -r chem -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","chem",s/60/60,(s/60/60)/'$chemalloc'*100}'
sacct -r health -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","health",s/60/60,(s/60/60)/'$healthalloc'*100}'
sacct -r hawkcpu -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","hawkcpu",s/60/60,(s/60/60)/'$hawkcpualloc'*100}'
sacct -r hawkgpu -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","hawkgpu",s/60/60,(s/60/60)/'$hawkgpualloc'*100}'
sacct -r hawkmem -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","hawkmem",s/60/60,(s/60/60)/'$hawkmemalloc'*100}'
sacct -r infolab -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","infolab",s/60/60,(s/60/60)/'$infolaballoc'*100}'
#sacct -r all-cpu,all-gpu,test,test-gpu -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
#    awk '{s+=$NF}END{printf " %12s: %12.2f  %8.2f%\n","all-cpu/gpu",s/60/60,(s/60/60)/'$totalalloc'*100}'
echo "========================================"
echo "Usage by PI"
for pi in $(sacct -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Account%15  | tail -n +3 | sort |  uniq )
do
  usage=$(sacct -a -A ${pi} --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{if ( $1 ~ /bio-s/){s+=$NF/24}else{s+=$NF}}END{print s/60/60}')
  echo $pi $usage $totalalloc | awk '{printf " %12s: %12.2f %8.2f%\n",$1,$2,$2/$3*100}'
done
echo "===================================="
echo "Monthly Sol Usage: $(date -d "$prevmonth month ago" +"%B, %Y")"
exit

exit

