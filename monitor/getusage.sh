#!/bin/bash


cd /home/alp514/monitor

export PATH=/share/Apps/usr/bin:/usr/local/bin:$PATH

sinfofmt="%.10N;%.12R;%.14C;%.10O;%.12m;%.12e"
squeuefmt="%.10i;%.10P;%.20j;%.8u;%.15a;%.10T;%.10M;%.20S;%.20V;%.12l;%.4C;%.4D;%.8m;%.20N;%.20r;%.12Q;%b"
squeueFMT="JobID,Partition,Name,UserName,Account,State,TimeUsed,StartTime,SubmitTime,TimeLimit,NumCPUs,NumNodes,ReasonList,PriorityLong,tres-per-node"


squeue --format="$squeuefmt" --states=PENDING,RUNNING | egrep -v 'vdi|singularity' | sed -e 's/gpu://g' -e 's/gres://g' -e 's/TRES_PER_NODE/GPUs/g' | sed 's/\r//' > queue.csv
#squeue --format="$squeueFMT" --states=PENDING,RUNNING | egrep -v 'vdi|singularity' > queue.csv
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT,PREEMPTED,NODE_FAIL,OUT_OF_MEMORY" -S $(date -d "today" +%Y-%m-%d-00:00:00) -E $(date -d "now" +%Y-%m-%d-%H:%M:%S) -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
  sed 's/\r//' | \
  egrep -v 'pavo|vdi|singularity' > jobs.csv

# Use R built for CentOS 8.x
#export PATH=/share/Apps/R/conda/4.7.12/bin:${PATH}
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}/share/Apps/R/conda/4.7.12/lib
#export PATH=/share/Apps/anaconda3/2020.07/envs/r/bin:${PATH}
#export LD_LIBRARY_PATH=/lib64:${LD_LIBRARY_PATH}:/share/Apps/anaconda3/2020.07/envs/r/lib

sinfo -N --format="$sinfofmt" -p lts,im1080,eng,engc,enge,himem-long,engi,im2080,chem,health,infolab,hawkcpu,hawkmem,hawkgpu,pisces,ima40-gpu | sed -e 's_N/A_0.0_g' -e 's/himem-long/himem/g' > load.csv

sinfo -N --format="%.10N;%.12R;%.12G" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu,hawkgpu,pisces,ima40-gpu | sed -e 's/gpu://g' | egrep -v null > gpuinfo.csv
#squeue --format="%.20N;%.12P;%.12b" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu,hawkgpu,pisces -t RUNNING | sed -e 's/gpu://g' -e 's/gres://g' | egrep -v 'null|N/A'  > gpuload.csv
squeue --format="%.20N %.12P %.12b %.6D" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu,hawkgpu,pisces,ima40-gpu  -t RUNNING | sed -e 's/gpu://g' -e 's/gres://g' | egrep -v 'null|N/A' | awk '{print $1,";",$2,";",$3*$4}' > gpuload.csv

export TMPDIR=/tmp
export TMP=/tmp
singularity exec /share/Apps/virtualapps/rstudio/rstudio-r402-base.sif R -e "rmarkdown::render('load.Rmd')"
scp -r load.html webapps:/srv/projects/hpc/monitor/

hour=$(date +%H)
min=$(date +%M)

if [[ ${hour} == "00" ]]; then
  if [[ ${min} > "10" && ${min} < 20 ]]; then
    cd /home/alp514/dashboard
    #scp -rp apacheco@mira.cc.lehigh.edu:/home/apacheco/grafana/sol-power/tmp.csv /home/alp514/dashboard
    singularity exec /share/Apps/virtualapps/rstudio/rstudio-r402-base.sif R -e "source('sol.R')" 
    rm -rf tmp.csv
    cd /home/alp514/monitor
    ./getusage-1.sh > usage1.dat
  fi
fi



