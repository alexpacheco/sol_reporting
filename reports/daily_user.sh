#!/bin/bash

# Execute getopt on the arguments passed to this program, identified by the special character $

PARSED_OPTIONS=$(getopt -n "$0" -o hd:p:u: --long "help,days=:,pi=:,user=:"  -- "$@")

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
  case "$1" in
    -h|--help)
      echo "This script reports the usage for user or pi"
      echo "Usage: daily_user.sh [OPTIONS] "
      echo "   -d <num>, --day=<num>: Report daily usage on <num> days ago"
      echo "   -p <investor username>, --pi=<investor username>: Report usage on allocation <investor username>."
      echo "   -u <username>, --user=<username>: Report usage for user <username>. PI's can use all, to report report for all users in their allocation" 
      echo "   -s <num>, --since=<num>: Report usage since <num> days ago until end of day yesterday"
      echo "   -h, --help: Print the help information"
      exit
      shift
      ;;
    -d | --day=* )
      shift
      if [ -n "$1" ]
      then
        day=$1
      else
        day=1
      fi
      shift
      ;;
    -p | --pi=*)
      shift
      if [ -n "$1" ]; then
        invest="-A $1"
      else
        invest=""
      fi
      shift
      ;;
    -u | --user=* )
      shift
      if [ -n "$1" ]; then
        investuser="-u $1"
      else
        investuser=""
      fi
      shift
      break
      ;;    
    --)
#      echo "Monthly Usage Report for the last $last months"
      shift
      break
      ;;
  esac
done


start=$(date -d "$day day ago" +%Y-%m-%d-00:00:00)
end=$(date -d "$day day ago" +%Y-%m-%d-23:59:59)

dailysu=$(sinfo -l -N --Format=cpus -p lts,imlab,eng,engc | awk '{s+=$1}END{print s*24}')

difftime=86400

#echo $tic $tock $difftime

echo "Daily Sol Usage: $(date -d "$day day ago" +%Y-%m-%d)"

echo "====================================================================================="
sacct -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o JobID%8,User%8,JobName%20,Partition%10,Account%8,AllocCPUS%10,CPUTimeRAW%15 |\
    awk '{if ( $4 ~ /bio-s/){s+=$NF/24}else{s+=$NF};print $0}END{cur=s/60/60;\
        print "=====================================================================================";\
	print "Usage:", cur,"\n% Use:",cur/(24*780)*100;
        print "====================================================================================="}'
echo "Usage by Partition"
sacct -r lts -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %6s: %12.2f %8.2f%\n","lts",s/60/60,(s/60/60)/(9*20*24)*100}'
sacct -r imlab,imlab-gpu -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %6s: %12.2f %8.2f%\n","imlab",s/60/60,(s/60/60)/(25*24*24)*100}'
sacct -r eng -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %6s: %12.2f %8.2f%\n","eng",s/60/60,(s/60/60)/(8*24*24)*100}'
sacct -r engc,engc-gpu -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %6s: %12.2f %8.2f%\n","engc",s/60/60,(s/60/60)/(13*24*24)*100}'
sacct -r himem,himem-long -a $invest $investuser --state=COMPLETED,CANCELLED,FAILED,TIMEOUT --starttime=$start --endtime=$end -X -o Partition,CPUTimeRAW | \
    awk '{s+=$NF}END{printf " %6s: %12.2f %8.2f%\n","himem",s/60/60,(s/60/60)/(1*16*24)*100}'
echo "====================================================================================="
exit

