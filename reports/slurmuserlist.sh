#!/bin/bash

sacctmgr list user | sort -k 2 | egrep -i 'User'
sacctmgr list user | sort -k 2 | egrep -iv 'Admin'


#sacct --accounts=lts -X --starttime=2016-08-01 | awk '{if ($6 ~ /COMPLETED/){s+=$(NF-2)}}END{print s/60/60}'


#sacctmgr list account | tail -n +3 | awk '{print $1}'


for pi in $(sacctmgr list account | tail -n +3 | awk '{print $1}') 
do
  echo $pi | awk '{printf "%6s ", $1}'
  sacct --accounts=$pi -X --starttime=2016-08-01 | awk '{if ($6 ~ /COMPLETED/){s+=$(NF-2)}else{s+=0}}END{printf "   %12.2f\n",s/60/60}'
done
