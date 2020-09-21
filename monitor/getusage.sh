#!/bin/bash


cd /home/alp514/monitor

export PATH=/share/Apps/usr/bin:/usr/local/bin:$PATH

sinfofmt="%.10N;%.12R;%.14C;%.10O;%.12m;%.12e"
squeuefmt="%.10i;%.10P;%.20j;%.8u;%.15a;%.10T;%.10M;%.20S;%.20V;%.12l;%.4C;%.4D;%.8m;%.20N;%.20r;%.12Q"


squeue --format="$squeuefmt" --states=PENDING,RUNNING | egrep -v 'vdi|singularity' > queue.csv
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT" -S $(date -d "today" +%Y-%m-%d-00:00:00) -E $(date -d "now" +%Y-%m-%d-%H:%M:%S) -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
  egrep -v 'pavo|vdi|singularity' > jobs.csv

export PATH=/share/Apps/R/conda/2019.10/bin:${PATH}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}/share/Apps/R/conda/4.3.31/lib

sinfo -N --format="$sinfofmt" -p lts,im1080,eng,engc,enge,himem-long,engi,im2080,chem | sed -e 's_N/A_0.0_g' -e 's/himem-long/himem/g' > load.csv

sinfo -N --format="%.10N;%.12R;%.5G" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu | sed -e 's/gpu://g' | egrep -v null > gpuinfo.csv
squeue --format="%.20N;%.12P;%.5b" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu -t RUNNING | sed -e 's/gpu://g' | egrep -v null  > gpuload.csv

R -e "rmarkdown::render('load.Rmd')"
scp -rp load.html webapps:/srv/projects/hpc/monitor/

hour=$(date +%H)
min=$(date +%M)

if [[ ${hour} == "00" ]]; then
  if [[ ${min} > "10" && ${min} < 20 ]]; then
    cd /home/alp514/dashboard
    scp -rp apacheco@aldebaran.cc.lehigh.edu:/data/apacheco/sol-power/tmp.csv .
    R -e "source('sol.R')" 
    cd /home/alp514/monitor
    ./getusage-1.sh > usage1.dat
  fi
fi



