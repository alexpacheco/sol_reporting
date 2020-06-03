#!/bin/bash

state="COMPLETED,CANCELLED,FAILED,TIMEOUT"
start=$(date -d "7 day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "1 day ago" +%Y-%m-%d-23:59:59)
sdate=$(date -d "7 day ago" +"%b %d")
edate=$(date -d "1 day ago" +"%b %d")

dailysu=$(sinfo -l -N --Format=cpus -p lts,imlab,eng,engc,himem,enge | awk '{s+=$1}END{print s*24*7}')

difftime=86400

#echo $tic $tock $difftime


for pi in $(sacct -a --state=$state --starttime=$start --endtime=$end -X -o Account%15 | tail -n +3 | sort | uniq)
do 
  for user in $(sacct -a -A $pi --state=$state --starttime=$start --endtime=$end -X -o User | tail -n +3 | sort | uniq )
  do
    cp /home/alp514/bin/pe.html tmp.$$
    name=$(ldapsearch -x -LLL -h nis.cc.lehigh.edu -b dc=lehigh,dc=edu uid=$user | grep "cn:" | awk -F: '{printf "%s",$2}')
    pionly=$(echo $pi | sed -e 's/_1718//g')
    piname=$(ldapsearch -x -LLL -h nis.cc.lehigh.edu -b dc=lehigh,dc=edu uid=$pionly | grep "cn:" | awk -F: '{printf "%s",$2}') 
    usage=($(sacct -u $user  -A ${pi} --state=$state --starttime=$start --endtime=$end -X -o CPUTimeRAW -n | \
      awk '{s+=$1}END{printf " %8d %12.2f\n",NR,s/60/60}'))
    if [[ "$user" == "cguser" ]]; then
       email="jul316@lehigh.edu"
    else
       email="${user}@lehigh.edu"
    fi
    if [[ "$pionly" == "mem-vdf" ]]; then
       piemail="ebw210@lehigh.edu"
       piname=$(ldapsearch -x -LLL -h nis.cc.lehigh.edu -b dc=lehigh,dc=edu uid=ebw210 | grep "cn:" | awk -F: '{printf "%s",$2}')
    elif [[ "$pionly" == "bioe495" ]]; then
       piemail="woi216@lehigh.edu"
       piname="BIOE 495 Course"
    else
       piemail="${pionly}@lehigh.edu"
    fi
    if [[ "${usage[0]}" -gt 0 ]]; then 
      echo "
Dear $name,
<br/ >
Please review your Sol usage for the duration $sdate through $edate. For efficient running of Sol that benefits all users in terms of wait time, users are expected to correctly estimate the amount of resources requested; nodes, cores and wall time. Over the last few weeks, we have noticed a majority of users are requesting either a two or three wall time even for jobs that do not run for more than an hour. Backfilling is enabled on the Sol cluster but it is useful only when resources requested can fit within the <a href="https://webapps.lehigh.edu/hpc/training/lurc/slurm.html#23">backfilling window</a>. <br />


The table below provides information of your usage for the past week. Here's what you need to evaluate<br />
<ul>
  <li>If the TimeUsed is greater than 75% of the TimeRequested, then you are estimating your resources very well.</li>
  <li>If the TimeUsed is less than a few minutes, then most likely you have a submit script or input error that I hope you are correcting the script before resubmitting your job.</li>
  <li>If the TimeUsed is less than 50% of the TimeRequested, then you need to pay more attention to the jobs you are running. </li>
</ul>
It may not be possible to estimate the time required for every job especially if you are submitting many jobs at once. If you notice a pattern in the actual time used, then you might have a better estimate for future jobs. Remember, even if the submit script worked for you previously, someone handed you a script that works for him/her or you copied one from the some online documentation including ours, it is your responsibility to understand your job requirements and edit the script accordingly.<br />

If you have questions or need help, please feel free to contact me. 


 " >> tmp.$$
    
      
      echo "<br /><br />" >> tmp.$$
      echo "<br /><br />" >> tmp.$$
      echo "<br />User: $name" >> tmp.$$
      echo "<br />PI: $piname" >> tmp.$$
      echo "<br />Usage: ${usage[1]} SUs" >> tmp.$$
      echo "<br />Number of Jobs: ${usage[0]}" >> tmp.$$
      percent=$(echo ${usage[1]} ${dailysu} | awk '{printf " %8.2f\n",$1/$2*100}')
      echo "<br />% of Available SUs used: ${percent}" >> tmp.$$ 
      echo "<br /><br />" >> tmp.$$
      echo "<table>" >> tmp.$$
      echo JobID User JobName Partition Account AllocCPUS TimeRequested TimeUsed | \
             awk 'BEGIN{printf "<tr>"}{for (i=1;i<=NF;i++){printf "<th> %s </th>",$i}}END{printf "</tr>\n"}' >> tmp.$$
      sacct -u ${user} -A ${pi} --state=$state --starttime=$start --endtime=$end -n -X -o JobID%8,User%8,JobName%20,Partition%18,Account%15,AllocCPUS%10,Timelimit%15,Elapsed%15 | \
        awk '{{printf "<tr><td> %s </td>",$1};for (i=2;i<=NF-1;i++){printf "<td> %s </td>",$i};printf "<td> %s </td></tr>\n",$NF}' >> tmp.$$
      echo "</table>" >> tmp.$$
    fi
    cat tmp.$$ | mail -r alp514@lehigh.edu -s "$(echo -e "Sol Stats: $sdate - $edate \nContent-Type: text/html")" $email alex.pacheco@lehigh.edu
    echo 
  done
done



