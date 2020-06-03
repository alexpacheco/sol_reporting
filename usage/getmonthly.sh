#!/bin/bash


month=$(date -d "$1 month ago" +%b | tr '[:upper:]' '[:lower:]')

mkdir -p ${HOME}/usage/${month}

cd ${HOME}/usage/${month}

sh ${HOME}/usage/monthlyusage.sh
