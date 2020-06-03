#!/bin/bash

if [[ $# -lt 2 ]]
then
  echo "Need Two Arguments"
  echo "$0 <start date> <end date>"
  exit
else
  start="$1-00:00:00"
  end="$2-23:59:59"
fi

today=$(date -d "today" +%s)
startdate=$(date -d "$1" +%s)

if [[  $today -lt $startdate ]] ; then
  exit
fi


state="COMPLETED,FAILED,TIMEOUT,CANCELLED"
options="-S $start -E $end -s $state"

serial=($(sacct -a $options -o CPUTimeRAW,NCPUS,NNodes -X -n  | \
  awk '{ p+=$(NF-2); q+=1; \
     if ( $NF == 1 && $(NF-1) == 1) {r+=1;s+=$(NF-2)} \
     } END { \
     printf "%10d %12.2f  %6.2f  %6.2f\n",r,s/60/60,r/q*100,s/p*100}'))

single=($(sacct -a $options -o CPUTimeRAW,NCPUS,NNodes -X -n  | \
  awk '{ p+=$(NF-2); q+=1; \
     if ( $NF == 1 && $(NF-1) > 1 ) {r+=1;s+=$(NF-2)} \
     } END { \
     printf "%10d %12.2f  %6.2f  %6.2f\n",r,s/60/60,r/q*100,s/p*100}'))

multi=($(sacct -a $options -o CPUTimeRAW,NCPUS,NNodes -X -n  | \
  awk '{ p+=$(NF-2); q+=1; \
     if ( $NF > 1) {r+=1;s+=$(NF-2)} \
     } END { \
     printf "%10d %12.2f  %6.2f  %6.2f\n",r,s/60/60,r/q*100,s/p*100}'))

total=($(sacct -a $options -o CPUTimeRAW,NCPUS,NNodes -X -n  | \
  awk '{ p+=$(NF-2); q+=1; \
     r+=1;s+=$(NF-2) \
     } END { \
     printf "%10d %12.2f  %6.2f  %6.2f\n",r,s/60/60,r/q*100,s/p*100}'))

month=$(date -d $1 +"%B %Y")

echo Number of Jobs Serial Single Multi Total
echo $month ${serial[0]} ${single[0]} ${multi[0]} ${total[0]} | awk '{printf " %12s %4d  %10d  %10d   %10d  %10d\n",$1,$2,$3,$4,$5,$6}'
echo SUs consumed
echo $month ${serial[1]} ${single[1]} ${multi[1]} ${total[1]} | awk '{printf " %12s %4d  %12.2f  %12.2f   %12.2f  %12.2f\n",$1,$2,$3,$4,$5,$6}'
echo Number of Jobs
echo $month ${serial[2]} ${single[2]} ${multi[2]} ${total[2]} | awk '{printf " %12s %4d  %6.2f  %6.2f   %6.2f  %6.2f\n",$1,$2,$3,$4,$5,$6}'
echo SUs consumed
echo $month ${serial[3]} ${single[3]} ${multi[3]} ${total[3]} | awk '{printf " %12s %4d  %6.2f  %6.2f   %6.2f  %6.2f\n",$1,$2,$3,$4,$5,$6}'

