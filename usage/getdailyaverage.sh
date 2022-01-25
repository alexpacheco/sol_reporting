#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/share/Apps/lusoft/opt/spack/linux-centos8-haswell/gcc-8.3.1/gnuplot/5.2.8-yqvp7hh/bin:$PATH
#export PATH=/share/Apps/R/conda/4.3.31/bin:$PATH

cd /home/alp514/usage

./dailyaverage.sh 2
./dailygpu.sh 2

#gnuplot onepage.gnu
gnuplot onepage-avg.gnu

#./getuserdaily.sh

mday=$(date -d "today" +%d | awk '{print int($1)}') 
#if [[ "$mday" -ge 4 ]] ; then
#  gnuplot monthly.gnu 2>/dev/null
#fi
#gnuplot daily.gnu 2>/dev/null
#gnuplot canvas.gnu 2>/dev/null

export TMP=${HOME}/JOB_TMPDIR
#Rscript -e "rmarkdown::render('dygraph.Rmd')"


COMMIT_TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S %Z'`
GIT=`which git`

${GIT} commit -am "Updated Sol Metrics at ${COMMIT_TIMESTAMP}"

${GIT} push web master

export PATH=/share/Apps/lusoft/opt/spack/linux-centos8-x86_64/gcc-8.3.1/rclone/1.53.3-meqi3gu/bin:$PATH
rclone copy -P -L ~/usage dropbox:sol_reporting/usage

