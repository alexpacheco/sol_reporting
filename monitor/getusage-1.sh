#!/bin/bash


cd /home/alp514/monitor

echo "Get this months usage"
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT" \
    -S $(date -d "1 day ago" +%Y-%m-01-00:00:00) \
    -E $(date -d "1 day ago" +%Y-%m-%d-23:59:59) \
    -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
    egrep -iv 'pavo|vdi|singularity' | sed 's/_1819//g' | sed 's/_1920//g' > jobs-0.csv
ls -ltr jobs-0.csv

echo "Get yesterdays usage"
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT" \
    -S $(date -d "1 day ago" +%Y-%m-%d-00:00:00) \
    -E $(date -d "1 day ago" +%Y-%m-%d-23:59:59) \
    -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
    egrep -iv 'pavo|vdi|singularity' | sed 's/_1819//g' | sed 's/_1920//g' > jobs-1.csv
ls -ltr jobs-1.csv

today=$(date +%d)

if [[ "$today" == "01" ]]; then
  tail -n +2 jobs-0.csv | gzip >> jobsalloc.csv.gz
  for part in lts im1080 eng engc enge engi himem-long im2080 chem
  do
    sbatch -p ${part} -t 1 -n 1 -J aysub jobsub.sh
  done
#  cat jobs-0.csv >> jobsalloc.csv
fi

echo "Compile annual report"
export PATH=/share/Apps/usr/bin:/usr/local/bin:/share/Apps/R/conda/2019.10/bin:$PATH
#R -e "rmarkdown::render('ay1718.Rmd')"
#scp -rp ay1718.html webapps:/srv/projects/hpc/monitor/
#R -e "rmarkdown::render('ay1819.Rmd')"
#scp -rp ay1819.html webapps:/srv/projects/hpc/monitor/
R -e "rmarkdown::render('ay1920.Rmd')"
scp -rp ay1920.html webapps:/srv/projects/hpc/monitor/

if [[ "$today" == "01" ]]; then
  scancel -n aysub -u alp514
  rm -rf slurm*out
fi

exit
for node in $(sinfo -N -h | awk '{print $1}'); do echo "$node;"https://grafana.cc.lehigh.edu/dashboard/db/server-statistics?orgId=1\&var-server=${node}\&from=now-3h\&to=now";"https://grafana.cc.lehigh.edu/d/000000047/ipmi-readings?orgId=1\&var-host=${node}\&from=now-3h\&to=now";"https://grafana.cc.lehigh.edu/d/000000042/telegraf-metrics?orgId=1\&var-datasource=default\&var-server=${nodes}\&var-inter=1m""; done | sed -e 's/\\&/\&/g' -e 's/pavo2/sol/g' > urls.csv

