#!/bin/bash

export PATH=/share/Apps/R/conda/2019.10/bin:/usr/local/bin:/usr/bin:$PATH

cd /home/alp514/dashboard

./getreport $(date -d "yesterday" +%Y-%m-%d) | tee -a soldaily.csv
./getreport $(date -d "yesterday" +%Y-%m-%d) | tee -a soldaily1920.csv

mday=$(date -d "today" +%d | awk '{print int($1)}') 
R -e "rmarkdown::render('dashboard.Rmd')"
if [[ "$mday" -ge 2 ]] ; then
 scp -rp dashboard.html dashboard.Rmd webapps:/srv/projects/hpc/usage/ 
 scp -rp dashboard.html dashboard.Rmd webapps:/home/alp514/public_html/sol-metrics/
else
 scp -rp dashboard.html dashboard.Rmd webapps:/home/alp514/public_html/sol-metrics/
fi


