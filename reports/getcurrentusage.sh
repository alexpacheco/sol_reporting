#/bin/bash

hour=$(date +%H)
min=$(date +%M)

cd /home/alp514/monitor

#./createhtml.sh >  currentusage.html 2>&1 
#./createprivate.sh > fullusage.html 2>&1 

#scp -rp currentusage.html fullusage.html webapps:/srv/projects/hpc/monitor/

export TMP=${HOME}/JOB_TMPDIR
./getusage.sh

#scp -rpv /home/alp514/monitor/load.html webapps:/srv/projects/hpc/monitor/
#scp -rpv apacheco@mira.cc.lehigh.edu:/home/apacheco/grafana/sol-power/tmp.csv /home/alp514/dashboard

exit

