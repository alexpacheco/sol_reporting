#/bin/bash

hour=$(date +%H)
min=$(date +%M)

cd /home/alp514/monitor

./createhtml.sh >  currentusage.html 2>&1 
./createprivate.sh > fullusage.html 2>&1 

scp -rp currentusage.html fullusage.html webapps:/srv/projects/hpc/monitor/

./getusage.sh

exit

