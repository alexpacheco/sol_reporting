#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/share/Apps/gnuplot/5.0.3/bin:$PATH
export LD_LIBRARY_PATH=/share/Apps/gcc/6.1.0/lib64
export PATH=/share/Apps/R/conda/4.3.31/bin:$PATH

cd /home/alp514/usage

./dailyaverage.sh 2
./dailygpu.sh 2

#./getuserdaily.sh

mday=$(date -d "today" +%d | awk '{print int($1)}') 
#if [[ "$mday" -ge 4 ]] ; then
#  gnuplot monthly.gnu 2>/dev/null
#fi
#gnuplot daily.gnu 2>/dev/null
#gnuplot canvas.gnu 2>/dev/null

Rscript -e "rmarkdown::render('dygraph.Rmd')"


COMMIT_TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S %Z'`
GIT=`which git`

${GIT} commit -am "Updated Sol Metrics at ${COMMIT_TIMESTAMP}"

${GIT} push web master


