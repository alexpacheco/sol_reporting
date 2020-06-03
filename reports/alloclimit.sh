#!/bin/bash

# Execute getopt on the arguments passed to this program, identified by the special character $

PARSED_OPTIONS=$(getopt -n "$0" -o ham:p:u: --long "help,all,months=:,pi=:,user=:"  -- "$@")

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
  case "$1" in
    -h|--help)
      echo "This script reports the usage of your allocation"
      echo "Usage: solreport [OPTIONS] "
      echo "   -m <num>, --months=<num>: Report usage for the last <num> months"
      echo "   -p <investor username>, --pi=<investor username>: Report usage on allocation <investor username>."
      echo "   -u <username>, --user=<username>: Report usage for user <username>. PI's can use all, to report report for all users in their allocation" 
      echo "   -h, --help: Print the help information"
      echo "Output is in CSV Format"
      echo "    General HPC Users: UserID ; Name ; Allocation Usage ; Usage in the current month; Usage for last <num> months in <num> column"
      echo "    Principal Investigators:"
      echo "              Total Allocation Usage:   UserID   Allocation Used  Allocation Limit"
      echo "              Usage for all users   :   UserID ; Name ; Allocation Usage ; Usage in the current month; Usage for last <num> months in <num> column"
      exit
      shift
      ;;
    -a | --all)
      alloconly=1
      shift
      ;;
    -m | --months=* )
      shift
      if [ -n "$1" ]
      then
        if [[ "$1" -gt "12" ]] ; then
          echo "Can provide Reports for last 12 months only"
          exit
        fi
        last=$1
      fi
      shift
      ;;
    -p | --pi=*)
      shift
      if [ -n "$1" ]; then
        invest=$1
	if [[ "$invest" == "all" ]] ; then
          invest=""
        fi
       else
        invest=""
      fi
      shift
      ;;
    -u | --user=* )
      shift
      if [ -n "$1" ]; then
        investuser=$1
        if [[ "$investuser" == "all" ]] ; then
          investuser=""
        fi
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

ay="_1718"

let nextlast=$last-1
# Get list of PIs
if [ -z $invest ]; then
#  accounts=$(sshare -o Account -n | awk '{print $1}' | uniq | egrep -iv 'description|suleiman')
  accounts=$(sshare -o Account -n | awk '{print $1}' | uniq)
else
  accounts=$invest
fi

alloclimit=-1
#start=$(date -d "-$last month" +%F-00:00:00)
#end=$(date -d "this month" +%F-00:00:00)
start=($(date -d "this month" +%Y-%m-01-00:00:00))
end=($(date -d "today" +%F-00:00:00))
state="COMPLETED,CANCELLED,FAILED,TIMEOUT"
aystart="2017-10-01-00:00:00"

for i in $(seq 1 12); do
  start=(${start[@]} $(date -d "-$i month" +%Y-%m-01-00:00:00))
  let j=$i-1
  end=(${end[@]} $(date -d "-$j month" +%Y-%m-01-00:00:00))
done

if [[ "$USER" == "alp514" || "$USER" == "sma310" ]]
then
  echo "      PI              Usage             Limit      %Used"
  echo "--------------------------------------------------------"
fi

for pi in $accounts 
do
#  usage=$(sshare -o Account,RawUsage,GrpTRESMins -A ${pi}${ay} -n | egrep -v "^\s+" | awk '{print $2/60/60}')
  usage=$(sacct -a -A ${pi} --state=$state --starttime=$aystart -X -o CPUTimeRAW | awk '{s+=$1}END{printf "%12.2f\n",s/60/60}')
  alloclimit=$(sshare -o Account,RawUsage,GrpTRESMins -A ${pi}${ay} -n | egrep -v "^\s+" | awk -F= '{print $2/60}')
  if [[ "$pi" == "lts" || "$pi" == "che395" || "$pi" == "hpc2017" ]]; then alloclimit=0 ; fi
  if [[ "$alloclimit" -gt "0" ]]
  then
    usepercent=$(echo $usage $alloclimit | awk '{print $1/$2*100}')
  else
    usepercent=0
  fi
  if [[ "$USER"  == "$pi" || "$USER" == "alp514" || "$USER" == "sma310" ]]
  then
    [[ "$USER"  == "$pi" ]] && echo "    PI          Usage           Limit"
    [[ "$USER"  == "$pi" ]] && echo "---------------------------------------"
    echo $pi $usage $alloclimit $usepercent | awk '{printf " %8s\t%14.5f\t%14.5f\t%8.2f\n",$1,$2,$3,$4}'
  fi
  if [[ "$pi" == "woi216" && "$USER" == "sek316" ]]
  then
    echo "    PI          Usage           Limit"
    echo "---------------------------------------"
    echo $pi $usage $alloclimit $usepercent | awk '{printf " %8s\t%14.5f\t%14.5f\t%8.2f\n",$1,$2,$3,$4}'
  fi
done
 
