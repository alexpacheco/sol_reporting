#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args) < 2) {
  # default output file
  args[2] <- format(Sys.Date()-15, "%Y-%m-%d")
  args[3] <- format(Sys.Date()-1, "%Y-%m-%d")
} else if (length(args) < 3) {
  args[3] <- format(Sys.Date()-1, "%Y-%m-%d")
} 

library(tidyverse)
library(lubridate)
library(reshape2)
library(stringr)
library(knitr)

source("./ayfuncs.R")

jobs1617 <- c()
jobs1718 <- c()
jobs1819 <- c()
jobs1920 <- c()
jobs2021 <- c()
jobs2122 <- c()
jobsthismonth <- c()
if ( args[2] < as.Date("2017-10-01") ) { 
  jobs1617 <- read_delim(file = 'jobsay1617.csv.gz', delim = ";")
} 
if ( args[2] < as.Date("2018-10-01") & args[3] > as.Date("2017-09-30") ) {
  jobs1718 <- read_delim(file = 'jobsay1718.csv.gz', delim = ";")
}
if ( args[2] < as.Date("2019-10-01") & args[3] > as.Date("2018-09-30") ) {
  jobs1819 <- read_delim(file = 'jobsalloc1819.csv.gz', delim = ";")
}
if ( args[2] < as.Date("2020-10-01") & args[3] > as.Date("2019-09-30") ) {
  jobs1920 <- read_delim(file = 'jobsalloc1920.csv.gz', delim = ";")
}
if ( args[2] < as.Date("2021-10-01") & args[3] > as.Date("2020-09-30") ) {
  jobs2021 <- read_delim(file = 'jobsalloc2021.csv.gz', delim = ";")
}
if ( args[2] < as.Date("2022-10-01") & args[3] > as.Date("2021-09-30") ) {
  jobs2122 <- read_delim(file = 'jobsalloc.csv.gz', delim = ";")
  jobsthismonth <- read_delim(file = 'jobs-0.csv', delim = ";")
}

jobsthisay <- rbind(jobs1617,jobs1718,jobs1819,jobs1920,jobs2021,jobs2122,jobsthismonth) %>%
    separate(Account, c("Account", "year1", "year2") , sep="_", fill = "right") %>%
    select(-c("year1","year2"))

jobsthisay %>% 
  filter(Start > as.Date(args[2]) & End < as.Date(args[3])) %>%
  mutate(Year=year(End),Month=month(End,label=TRUE)) %>%
  group_by(Year,Month,User,Account) %>%
  summary %>% filter(Account == args[1]) %>% 
  kable()

jobsthisay %>%
  filter( Account == args[1] ) %>%
  filter(Start > as.Date(args[2]) & End < as.Date(args[3])) %>%
  mutate(`Wait Time (min)`=round(difftime(Start,Submit,units="mins"),2),
     `Run Time (min)`=round(difftime(End,Start,units="mins"),2),
     `SUs Consumed` =  round(difftime(End,Start,units="hour")*NCPUS,2)) %>%
  mutate_at(c("Wait Time (min)","Run Time (min)"), str_replace, " mins", "") %>%
  mutate_at(c("SUs Consumed"), str_replace, " hours", "") %>%
  select(-c(X14)) %>%
  arrange(desc(User)) %>%
  kable()

