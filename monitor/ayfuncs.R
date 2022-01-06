
# Summary Function
summary <- function(data) {
  data %>%
  select(c(Start,Submit,End,NCPUS)) %>% 
  mutate(
    WaitTime=round(difftime(Start,Submit,units="mins"),2),
    RunTime=round(difftime(End,Start,units="mins"),2),
    SUTime=round(as.numeric(difftime(End,Start,units="hours"))*NCPUS,2)
  ) %>% 
  mutate_at(c("WaitTime","RunTime"), str_replace, " mins", "") %>%
  mutate_at(c("SUTime"), str_replace, " hours", "") %>%
  summarize(
    SU=round(sum(as.numeric(SUTime)),2),
    Jobs=n(),
    Wait=round(mean(as.numeric(WaitTime)),2),
    Run=round(mean(as.numeric(RunTime)),2)
  )
}

# Monthly Summary Function
monthly_summary <- function(data) {
   data %>% 
   mutate(Year=year(End),Month=month(End,label=TRUE)) %>% 
   group_by(Year,Month) %>% 
   summary 
}

# Get Percentage of SUs and Jobs
getpercent <- function(data1,data2) { 
  full_join(data1,data2,join_by=c("Year","Month")) %>%
  mutate( 
    '% SU'=round(SU/Total_SU*100,2), 
    '% Jobs'=round(Jobs/Total_Jobs*100,2)
  ) %>% 
  select(c("Month","SU","Jobs","% SU","% Jobs","Wait","Run"))
}

# Get Monthly Usage and output to datatable
monthly_usage <- function(data,first,last) {
  data %>%
  filter( End >= first & End < last ) %>%
  mutate(`Wait Time (min)`=round(difftime(Start,Submit,units="mins"),2),
    `Run Time (min)`=round(difftime(End,Start,units="mins"),2),
    `SUs Consumed` =  round(difftime(End,Start,units="hour")*NCPUS,2)) %>%
  select(c(JobID:Timelimit,`Wait Time (min)`:`SUs Consumed`)) %>% 
  datatable(filter = 'top',
    options = list(
      dom = 'lptip', pageLength = 25, lengthMenu = c(25, 50, 100, 250, 500)
    )
  )
}
  #select(-c(Start,Submit,End,X14)) %>%

# Filters for serial, smp and dmp jobs
serial_filter <- function(data) {
  data %>% filter( NNodes == 1 & NCPUS == 1 )
}

smp_filter <- function(data) {
  data %>% filter( NNodes == 1 & NCPUS > 1 )
}

dmp_filter <- function(data) {
  data %>% filter( NNodes > 1 )
}


# Customize Tables
my_table <- function(data) {
  data %>% 
  datatable(
    rownames = FALSE,
    options = list(
      autoWidth = FALSE,
      pageLength = 25,
      order = list(list(1, 'desc'))
    )
  )
} 

my_longtable <- function(data){
  data %>%
  datatable(
    filter = 'top',
    rownames = FALSE,
    options = list(
      autoWidth = FALSE,
      pageLength = 50, lengthMenu = c(50,100,150,200,250),
      order = list(list(1, 'desc'))
    )
  )
}

# Summary for SU and Jobs per partition
partfilter <- function(data,partname,part) {
  data %>%
    mutate(Partition=partname,Used=round(SU/sum(part[1:currmonth])*100,2)) %>%
    select(c(Partition,SU,'% Consumed'=Used,Jobs,Wait,Run))
}

parttotalfilter <- function(data,part,parttotal) {
  data %>%
    mutate(Partition=part,
       SUper = round(SU/parttotal$SU*100,2),
       Jobsper = round(Jobs/parttotal$Jobs*100,2)) %>%
    select(c(Partition,SU,'% SU'=SUper,'% Jobs'=Jobsper,Jobs,Wait,Run))
}

partpercent <- function(data,part) {
  tmp <- as_tibble(part)
  bind_cols(data,tmp) %>% 
    mutate(Used=round(SU/value*100,2)) %>% 
    select(c(Year,Month,SU,'%Consumed'=Used,Jobs,Wait,Run))
}

# cpu vs gpu summary
cpu_gpu_total <- function(data,type) {
  data %>%
    group_by(.dots = lazyeval::lazy(type)) %>%
    summarize(Total=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

cpu_gpu_monthly <- function(data,type) {
  data %>%
    mutate(Year=year(End),Month=month(End,label=TRUE)) %>% 
    group_by(Year,Month) %>%
    summarize(Total=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

cpu_total <- function(data,type) {
  data %>%
    filter(!str_detect(Partition,'gpu')) %>%
    group_by(.dots = lazyeval::lazy(type)) %>%
    summarize(CPU=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

cpu_monthly <- function(data,type) {
  data %>%
    mutate(Year=year(End),Month=month(End,label=TRUE)) %>% 
    group_by(Year,Month) %>%
    filter(!str_detect(Partition,'gpu')) %>%
    summarize(CPU=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

gpu_total <- function(data,type) {
  data %>%
    filter(str_detect(Partition,'gpu')) %>%
    group_by(.dots = lazyeval::lazy(type)) %>%
    summarize(GPU=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

gpu_monthly <- function(data,type) {
  data %>%
    mutate(Year=year(End),Month=month(End,label=TRUE)) %>% 
    group_by(Year,Month) %>%
    filter(str_detect(Partition,'gpu')) %>%
    summarize(GPU=round(sum(as.numeric(difftime(End,Start,units="hours"))*NCPUS),2))
}

