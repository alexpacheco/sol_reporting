#!/bin/bash

ay=1718
aynow=$(echo $ay | cut -c 1-2 | awk '{printf "20%s\n",$1}')
aynext=$(echo $ay | cut -c 3-4 | awk '{printf "20%s\n",$1}')
accounts=$(sshare -o Account,RawUsage,GrpTRESMins | egrep -i $ay | awk -F_ '{print $1}')

echo $ay
echo $aynow
echo $aynext
echo $accounts

if [[ -z "$1" ]]
then
  day=1
else
  day="$1"
fi

start=$(date -d "$day day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$day day ago" +%Y-%m-%d-23:59:59)
echo $start,$end

DATE=$(date -d "$day day ago" +%Y/%m/%d)

difftime=86400
:
for pi in $accounts lts bioe495
do
  echo $DATE | awk '{printf " %10s ",$1}' >> userstats/$pi.dat
  sacct -a -A $pi,${pi}_${ay} --starttime=$start --endtime=$end -X --state=COMPLETED,CANCELLED,FAILED,TIMEOUT -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "  %9.2f\n",cur}' >> userstats/$pi.dat
  totalusage=$(sacct -a -A $pi,${pi}_${ay} \
	--starttime=$aynow-10-01-00:00:00 \
	--endtime=$end \
	-X --state=COMPLETED,CANCELLED,FAILED,TIMEOUT -o Partition,CPUTimeRAW%15 | \
	awk '{s+=$NF}END{cur=s/60/60;printf "  %9.2f\n",cur}')
  if [[ "$pi" == "lts" ]]; then
    alloclimit=-1
  else 
    alloclimit=$(sshare -o GrpTRESMins -A ${pi}_${ay} -n | awk -F= '{print $NF/60}')
  fi

  if [[ "$pi" == "bioe495" ]]; then
gnuplot << EOF

set term canvas rounded size 900,600 enhanced font 'Verdana' fsize 12 fontscale 1 standalone mousing jsdir "js"
set title "Daily Sol Usage: $pi"
set output '${pi}.html'

set xlabel 'Month/Day'
set ylabel 'SUs consumed'

set xdata time
set timefmt "%Y/%m/%d"
set yrange [0:]
set xrange [:]
#set xtics "20161001", 1209600
#set xtics ( "09/01", "09/15", \
#            "10/01", "10/15", \
#            "11/01", "11/15", \
#            "12/01", "12/15" )
set format x "%m/%d"
#set mxtics 86400

set label "Total Usage: $totalusage SU" at graph 0.61,0.96
set label "Allocation Limit: $alloclimit SU" at graph 0.61,0.92

plot 'userstats/$pi.dat' u 1:2 lw 2 t '' smooth csplines

EOF
  else
gnuplot << EOF

set term canvas rounded size 900,600 enhanced font 'Verdana' fsize 12 fontscale 1 standalone mousing jsdir "js"
set title "Daily Sol Usage: $pi"
set output '${pi}.html'

set xlabel 'Month/Day'
set ylabel 'SUs consumed'

set xdata time
set timefmt "%Y/%m/%d"
set yrange [0:]
#set xrange [$aynow/10/01:$aynow/11/01]
#set xtics "20161001", 1209600
#set xtics ( "10/01", "11/01", "12/01", \
#            "01/01", "02/01", "03/01", \
#            "04/01", "05/01", "06/01", \
#            "07/01", "08/01", "09/01", "10/01" ) 
set format x "%m/%d"
#set mxtics 86400

set label "Total Usage: $totalusage SU" at graph 0.61,0.96
set label "Allocation Limit: $alloclimit SU" at graph 0.61,0.92

plot 'userstats/$pi.dat' u 1:2 lw 2 t '' smooth csplines

EOF
  fi


done
