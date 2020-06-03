#!/bin/bash

export PATH=/usr/local/bin:$PATH

cd /tmp

numdays=$(cal $(date -d "1 month ago" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')

start=$(date -d "1 month ago" +%Y-%m-01-00:00:00)
end=$(date -d "1 day ago" +%Y-%m-%d-23:59:59)

#for pi in $(sacct -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Account  | tail -n +3 | sed 's/_1718//g' | sort | uniq )
for pi in $(sacct -a --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Account | tail -n +3 | awk -F_ '{print $1}' | awk '{for (i=1;i<=NF;i++){printf "%s\n",$i}}' | sort | uniq)
do
  /home/alp514/bin/daily_alloc.sh $pi $numdays 1 > tmp.$$
  if [[ "$pi" == "che395" ]]
  then
    recv="srr516@lehigh.edu jem309@lehigh.edu"
  elif [[ "$pi" == "cse498" ]]
  then
    recv="mcc7@lehigh.edu"
  elif [[ "$pi" == "csereu" ]]
  then
    recv="bdd3@lehigh.edu"
  elif [[ "$pi" == "bioe495" ]]
  then
    recv="woi216@lehigh.edu"
  elif [[ "$pi" == "mem-vdf" ]]
  then
    recv="ebw210@lehigh.edu alo2@lehigh.edu"
  elif [[ "$pi" == "ise" ]]
  then
    recv="tkr2@lehigh.edu"
  elif [[ "$pi" == "rof2" || "$pi" == "dav512" || "$pi" == "chem"]]
  then
    recv="laf218@lehigh.edu"
  elif [[ "$pi" == "hpc2017" || "$pi" == "hpc2018" || "$pi" == "lts" || "$pi" == "cse375" || "$pi" == "amr511" ]]
  then
    recv=
  else
    recv=$(echo $pi"@lehigh.edu") 
  fi
  month=$(date -d "1 month ago" +"%b, %Y")
  cat tmp.$$ | mail -r alp514@lehigh.edu -s "$(echo -e "Sol usage summary for $month")" $recv alex.pacheco@lehigh.edu
  #cat tmp.$$ | mail -r alp514@lehigh.edu -s "$(echo -e "Sol usage summary for $month")" alex.pacheco@lehigh.edu
done


