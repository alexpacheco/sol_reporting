#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:$PATH
#export PATH=/share/Apps/anaconda3/2020.07/envs/r/bin:/usr/local/bin:/usr/bin:$PATH

cd /home/alp514/dashboard
cp -p /tmp/sol_value.jpg .

./getreport $(date -d "yesterday" +%Y-%m-%d) | tee -a soldaily.csv
./getreport $(date -d "yesterday" +%Y-%m-%d) | sed -e 's/LTS Ctr for Inn. in Teach and/LTS/g' | tee -a soldaily2122.csv

mday=$(date -d "today" +%d | awk '{print int($1)}') 
export TMP=${HOME}/JOB_TMPDIR
singularity exec /share/Apps/virtualapps/rstudio/rstudio-r402-base.sif R -e "rmarkdown::render('dashboard.Rmd') ; rmarkdown::render('summary.Rmd'); rmarkdown::render('training.Rmd'); source('public_dash.R')"
if [[ "$mday" -ge 2 ]] ; then
 scp -rp dashboard.html dashboard.Rmd webapps:/srv/projects/hpc/usage/ 
 scp -rp dashboard.html dashboard.Rmd webapps:/home/alp514/public_html/sol-metrics/
else
 scp -rp dashboard.html dashboard.Rmd webapps:/home/alp514/public_html/sol-metrics/
fi

scp -rp sol_value.jpg webapps:/srv/projects/hpc/
scp -rp annual*html monthly*html total*html pidept*html user*html summary.html training.html cpu_gpu*.html *powerusage.html webapps:/srv/projects/hpc/public/

export PATH=/share/Apps/lusoft/opt/spack/linux-centos8-x86_64/gcc-8.3.1/rclone/1.53.3-meqi3gu/bin:$PATH
rclone copy -P ~/dashboard dropbox:sol_reporting/dashboard
cd flyer
singularity exec /home/alp514/latex-leap153.sif pdflatex lehighrc
singularity exec /home/alp514/latex-leap153.sif pdflatex lehighrc
rclone copy -P lehighrc.pdf dropbox:sol_reporting/dashboard/flyer
rclone copy -P lehighrc.pdf lugdrive:'Ads for New Faculty'/
