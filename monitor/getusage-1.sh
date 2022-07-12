#!/bin/bash


cd /home/alp514/monitor

echo "Get this months usage"
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT,PREEMPTED,NODE_FAIL,OUT_OF_MEMORY" \
    -S $(date -d "1 day ago" +%Y-%m-01-00:00:00) \
    -E $(date -d "1 day ago" +%Y-%m-%d-23:59:59) \
    -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
    sed 's/\r//' | \
    egrep -iv 'vdi|singularity' | sed -e 's/_2021/_2122/g' > jobs-0.csv
ls -ltr jobs-0.csv

echo "Get yesterdays usage"
sacct -a --state="COMPLETED,CANCELLED,FAILED,TIMEOUT,PREEMPTED,NODE_FAIL,OUT_OF_MEMORY" \
    -S $(date -d "1 day ago" +%Y-%m-%d-00:00:00) \
    -E $(date -d "1 day ago" +%Y-%m-%d-23:59:59) \
    -p --delimiter=";" \
    -X -o JobID%7,JobName%20,Partition%20,User%8,Account%20,NCPUS%4,NNodes%2,Nodelist%20,Elapsed%15,Timelimit%15,Submit,Start,End | \
    sed 's/\r//' | \
    egrep -iv 'vdi|singularity' | sed -e 's/_2021/_2122/g' > jobs-1.csv
ls -ltr jobs-1.csv

today=$(date +%d)

if [[ "$today" == "01" ]]; then
  tail -n +2 jobs-0.csv | gzip >> jobsalloc.csv.gz
  for part in lts im1080 eng engc enge engi himem-long im2080 chem health hawkcpu hawkmem hawkgpu infolab pisces ima40-gpu
  do
    sbatch -p ${part} -t 1 -n 1 -J aysub jobsub.sh
  done
#  cat jobs-0.csv >> jobsalloc.csv
fi

echo "Compile annual report"
#export PATH=/share/Apps/usr/bin:/usr/local/bin:/share/Apps/R/conda/4.7.12/bin:$PATH
export PATH=/share/Apps/usr/bin:/usr/local/bin:${PATH}
#export PATH=/share/Apps/usr/bin:/usr/local/bin:/share/Apps/anaconda3/2020.07/envs/r/bin:${PATH}
#export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
export TMPDIR=/tmp
export TMP=/tmp
#R -e "rmarkdown::render('ay1718.Rmd')"
#scp -r ay1718.html webapps:/srv/projects/hpc/monitor/
#R -e "rmarkdown::render('ay1819.Rmd')"
#scp -r ay1819.html webapps:/srv/projects/hpc/monitor/
#R -e "rmarkdown::render('ay1920.Rmd')"
#scp -r ay1920.html webapps:/srv/projects/hpc/monitor/
#R -e "rmarkdown::render('ay2021.Rmd')"
#scp -r ay2021.html webapps:/srv/projects/hpc/monitor/
singularity exec /share/Apps/virtualapps/rstudio/rstudio-r402-base.sif R -e "rmarkdown::render('ay2122.Rmd'); rmarkdown::render('cy2022.Rmd')"
scp -r ay2122.html cy2022.html webapps:/srv/projects/hpc/monitor/

export PATH=/share/Apps/lusoft/opt/spack/linux-centos8-x86_64/gcc-8.3.1/rclone/1.53.3-meqi3gu/bin:$PATH
rclone copy -P ~/monitor dropbox:sol_reporting/monitor

if [[ "$today" == "01" ]]; then
  scancel -n aysub -u alp514
  rm -rf slurm*out
fi

exit

