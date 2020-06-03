#!/bin/bash


sinfo -N --format="%.10N;%.12R;%.5G" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu | sed -e 's/gpu://g' | egrep -v null > gpuinfo.csv
squeue --format="%.20N;%.12P;%.5b" -p lts-gpu,eng-gpu,im1080-gpu,im2080-gpu -t RUNNING | sed -e 's/gpu://g' | egrep -v null  > gpuload.csv

Rscript gpuload.R



