
library(tidyverse)
library(stringr)

info <-  read_delim('gpuinfo.csv',delim=";",trim_ws=TRUE)
load <-  read_delim('gpuload.csv',delim=";",trim_ws=TRUE)

colnames(info) <- c('Node','Partition','Available')
colnames(load) <- c('Node','Partition','GPU')

load %>% group_by(Node,Partition) %>% summarize(Usage=sum(GPU)) -> usage

full_join(info,usage) -> gpuload

gpuload[is.na(gpuload)] <- 0

write_delim(gpuload,'gpuusage.csv',delim=";")



