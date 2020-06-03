#!/bin/bash

pwd=${PWD}
name=$(echo $0 | awk -F/ '{print $NF}')
host=$(hostname | awk -F. '{print $1}')
echo "Running $name on $host"
walltime="1:00:00"
nodes=1
ppn=1
queue=lts

# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0" -o ht:n:p:q:e: --long "help,time=:,nodes=:,ntasks-per-node=:,partition=:,exec=:"  -- "$@")

#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  exit 1
fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
  case "$1" in
    -h|--help)
      echo "usage $name [OPTIONS}"
      echo ""
      echo "Description: This script requests an interact session or runs an interact job on a sol compute node"
      echo ""
      echo "Options:"
      echo "    -h, --help: Display help information for $name"
      echo "    -t hh, --time=hh: Maximum walltime requested, upto 12 hours"
      echo "    -n <num>, --nodes=<num>: Number of nodes requested"
      echo "    -p <num>, --ntasks-per-node=<num>: Number of processors per node"
      echo "    -q <queuename>, --partition=<queuename>: Partition (Queue) to run the interactive session"
      echo "    -e <statement>, --exec=<statment>: command to run on interactive session (optional)"
      echo "             If -e,--exec option is not provided, the user will be provided with a command prompt on the compute node"
      exit;
      shift;
      ;;
    -t|--time=*)
      shift;
      if [ -n "$1" ];
      then
        if [[ "$1" -gt "12" && ${USER} != "alp514" ]]; then
           echo "Max Walltime allowed using idev is 12 hours, exiting";
           exit;
        fi 
        walltime="$1:00:00";
      fi
      shift;
      ;;
    -n|--nodes=*)
      shift;
      if [ -n "$1" ];
      then
        nodes=$1;
      fi
      shift;
      ;;
    -p|--ntasks-per-node=*)
      shift;
      if [ -n "$1" ];
      then
        ppn=$1;
      fi
      shift;
      ;;
    -q|--partition=*)
      shift;
      if [ -n "$1" ];
      then
        queue=$1;
      fi
      shift;
      ;;
    -e|--exec=*)
      shift;
      if [ -n "$1" ];
      then
        job="--pty $1";
        shift;
      fi
      ;;
    --)
      echo "Requested Walltime: $walltime";
      echo "Nodes Requested: $nodes";
      echo "Processors per node Requested: $ppn";
      echo "Queue to run jobs on: $queue";
      if [[ -z $job ]]; then
         echo "Interactive login to compute node"
         echo "Compute nodes names have a format sol-[a-z][1-4][0,1][1-9]"
	 echo "Running jobs on the head/login is strictly prohibited and"
         echo "   can lead to suspension of your HPC account"
	 job="--pty /bin/bash --login"
      else
	 echo "Command to execute: $job";
      fi
      shift;
      break;
      ;;
  esac
done

tic=$(date +%s)
case $host in
  sol)
    #salloc -t $walltime --nodes=$nodes --ntasks-per-node=$ppn -p $queue $job
    #srun -t $walltime -N $nodes -n $ppn -p $queue --pty $job
    srun -t $walltime --nodes=$nodes --ntasks-per-node=$ppn -p $queue --pty $job
    ;;
  *)
    echo "ERROR: THIS IS THE HEAD NODE, DO NOT RUN COMPUTE INTENSIVE JOBS HERE";
    break;
    ;;
esac

tock=$(date +%s)
tictock=$(echo $tock $tic | awk '{printf "%12.6f",($1-$2)/60/60}')
echo "Interactive Session completed"
suused=$(echo $tictock $nodes $ppn | awk '{printf "%12.6f",$1*$2*$3}')
echo "Total time (wait time + run time) was $tictock hours"

cd ${pwd}
exit
