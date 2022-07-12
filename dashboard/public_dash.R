library(tidyverse)
library(lubridate)
library(dygraphs)
library(xts)
library(htmlwidgets)
library(plotly)
library(ggplot2)
library(webshot)

data <- read.table('/home/alp514/usage/daily.csv', header = FALSE, sep = ",", col.names = paste0("V",seq_len(33)), fill = TRUE)
data[is.na(data)] <- 0

daily1617 <- read_delim('soldaily1617.csv', delim=";")
daily1718 <- read_delim('soldaily1718.csv', delim=";")
daily1819 <- read_delim('soldaily1819.csv', delim=";")
daily1920 <- read_delim('soldaily1920.csv', delim=";")
daily2021 <- read_delim('soldaily2021.csv', delim=";")
daily2122 <- read_delim('soldaily2122.csv', delim=";")
#daily2223 <- read_delim('/home/alp514/dashboard/soldaily2223.csv', delim=";")
ay1617su <- c(580320.00,561600.00,580320.00,580320.00,524160.00,580320.00,699840.00,955296.00,924480.00,955296.00,955296.00,924480.00)
ay1718su <- c(955296.00,924480.00,967200.00,967200.00,873600.00,967200.00,1117440.00,  1154688.00,1117440.00,1154688.00,1155480.00,1169280.00)
ay1819su <- c(1624*31,1696*30,1720*31,2152*31,2152*28,2152*31,2188*30,2188*31,2188*30,2188*31,2188*31,2188*30)*24
ay1920su <- c(2188*31,2188*30,2188*31,2188*31,2188*29,2188*31,2188*30,2188*31,2332*30,2332*31,2404*31,2404*30)*24
ay2021su <- c(2404*31,2404*30,2404*31,4260*31,4260*28,4260*31,4260*30,4260*31,4260*30,4260*31,4260*31,4260*30)*24
ay2122su <- c(4260*31,4260*30,4260*31,4260*31,4260*28,4260*31,4404*30,4404*31,4404*30,4404*31,4404*31,4404*30)*24
# If more resources get added modify this accordingly oct'22 - sep'23
ay2223su <- c(4404*31,4404*30,4404*31,4404*31,4404*28,4404*31,4404*30,4404*31,4404*30,4404*31,4404*31,4404*30)*24

# Modify these to add daily2223 and ay2223su after Oct 1
daily <- rbind(daily1617,daily1718,daily1819,daily1920,daily2021,daily2122)
aysu <- c(ay1617su,ay1718su,ay1819su,ay1920su,ay2021su,ay2122su)

# Create daily vector
aymonth<- seq(as.Date("2016-10-01"), as.Date("2022-09-30"), by = "month")
AYSU <- tibble(Month=aymonth,Available=aysu) %>% filter(Month <= today())
aydaily <- AYSU %>% mutate(Date = ymd(Month)) %>% group_by(Date) %>% expand(Date = seq(floor_date(Date, unit = "month"), today(), by="day"), Available)

### Monthly Usage 
length(aysu)
monthly <- daily %>%
  group_by(Month=floor_date(as.Date(Day),"month")) %>%
  summarize(Total=sum(as.double(Total))) %>%
  drop_na()
#monthly$Available <- aysu
monthly <- left_join(monthly,AYSU)
dateWindow = c(as.Date("2016-09-01") , today() + 31 )

# Get Monthly Usage 
monthlyusage <- dygraph( xts(cbind(monthly$Total,monthly$Available), order.by = monthly$Month)) %>%
  dySeries("V1", label = "Consumed", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "Total Available", color = "green", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyAxis("y", label = "CPU Hours per Month") %>%
  dyOptions(stackedGraph = FALSE, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE) %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyLegend(width = 400) %>%
  dyRoller(rollPeriod = 1) %>%
  dyEvent("2016-10-01", "Sol launched with 34 nodes, 760 cores", labelLoc = "top") %>% 
  dyEvent("2017-01-19", "34 nodes, 760 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-03-15", "42 nodes, 972 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-05-01", "55 nodes, 1284 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-11-15", "56 nodes, 1300 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-12-01", "56 nodes, 1300 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-04-02", "63 nodes, 1552 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-08-31", "65 nodes, 1624 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-11-12", "66 nodes, 1648 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-12-01", "68 nodes, 1720 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2019-01-02", "80 nodes, 2152 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2019-04-01", "81 nodes, 2188 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-05-31", "85 nodes, 2332 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-08-01", "87 nodes, 2404 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-11-12", "Hawk: User Friendly", labelLoc = "top") %>%
  dyEvent("2021-02-01", "Hawk in Production", labelLoc = "top") %>%
  dyEvent("2022-04-01", "127 nodes, 4404 cores, 181 GPUs", labelLoc = "top") %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlyusage$sizingPolicy$padding <- "0"
saveWidget(monthlyusage, file="monthlyusage.html")

#install phantom:
webshot::install_phantomjs()
# Make a webshot in pdf : high quality but can not choose printed zone
webshot("monthlyusage.html" , "monthlyusage.pdf", delay = 0.2)

# Make a webshot in png : Low quality - but you can choose shape
webshot("monthlyusage.html" , "monthlyusage.png", delay = 0.2 , cliprect = c(440, 0, 1000, 10))

# Get Monthly Usage and Jobs by Job Types 
sujobs <- daily %>%
  group_by(Month=floor_date(as.Date(Day),"month")) %>%
  summarize(Serial=sum(as.double(Serial)),SMP=sum(as.double(Single)),Multi=sum(as.double(Multi)),
            SerialJ=sum(as.double(SerialJ)),SMPJ=sum(as.double(SingleJ)),MultiJ=sum(as.double(MultiJ))) %>%
  drop_na()
monthlysus <- dygraph(xts(cbind(sujobs$Serial,sujobs$SMP,sujobs$Multi), order.by = sujobs$Month )) %>%
  dySeries("V1", label = "Serial", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "Single", color = "green", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V3", label = "Multi", color = "orange", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyOptions(stackedGraph = TRUE,axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE ) %>%
  dyAxis("y", label = "CPU Hours per Month") %>%
  dyLegend(show = "follow" ) %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlysus$sizingPolicy$padding <- "0"
saveWidget(monthlysus, file="monthlysus.html")

monthlyjobs <- dygraph(xts(cbind(sujobs$SerialJ,sujobs$SMPJ,sujobs$MultiJ), order.by = sujobs$Month ) ) %>%
  dySeries("V1", label = "Serial", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "Single", color = "green", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V3", label = "Multi", color = "orange", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyOptions(stackedGraph = TRUE,axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE ) %>%
  dyAxis("y", label = "Jobs per Month") %>%
  dyLegend(show = "follow") %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlyjobs$sizingPolicy$padding <- "0"
saveWidget(monthlyjobs, file="monthlyjobs.html")

# Get Pie charts for Single, SMP and Multi jobs since launch
totalsus_type <- sujobs %>% summarize(Serial=sum(Serial),Single=sum(SMP),Multi=sum(Multi)) %>% gather(Jobs,Usage,Serial:Multi) %>%
  plot_ly(values = ~Usage, labels = ~Jobs, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = F)
totaljobs_type <- sujobs %>% summarize(Serial=sum(SerialJ),Single=sum(SMPJ),Multi=sum(MultiJ)) %>% gather(Jobs,Usage,Serial:Multi) %>%
  plot_ly(values = ~Usage, labels = ~Jobs, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = F)
totalsus_type$sizingPolicy$padding <- "0"
totaljobs_type$sizingPolicy$padding <- "0"
saveWidget(totalsus_type, file="totalsus_type.html")
saveWidget(totaljobs_type, file="totaljobs_type.html")

# Get active users and pis
stats <- daily %>% 
  group_by(Month=floor_date(as.Date(Day),"month")) %>% 
  summarize(User=n_distinct(Name),Department=n_distinct(Department),PI=n_distinct(PI), PIDept=n_distinct(PIDept)) %>% 
  drop_na()
monthlyusers <- dygraph(xts(cbind(stats$User,stats$Department), order.by = stats$Month ) ) %>%
  dySeries("V1", label = "Active Users", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "Major/Department", color = "green", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyOptions(stackedGraph = FALSE, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE) %>%
  dyLegend(show = "follow") %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlyusers$sizingPolicy$padding <- "0"
#saveWidget(monthlyusers, file="monthlyuser.html")

# Pie chart of user vs major/department
totaluser_dept <- daily %>% group_by(Department) %>% summarize(User=n_distinct(Name)) %>% 
  plot_ly(values = ~User, labels = ~Department, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = T)
#totaluser_dept$sizingPolicy$padding <- "0"
#saveWidget(totaluser_dept, file="totaluser_dept.html")

monthlypi <- dygraph(xts(cbind(stats$PI,stats$PIDept), order.by = stats$Month ) ) %>%
  dySeries("V1", label = "PIs", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "PI's Department", color = "green", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyOptions(stackedGraph = FALSE, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE) %>%
  dyLegend(show = "follow") %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlypi$sizingPolicy$padding <- "0"
#saveWidget(monthlypi, file="monthlypi.html")

# Pie chart of PI's vs Department
totalpi_dept <- daily %>% group_by(PIDept) %>% summarize(PI=n_distinct(PI)) %>% 
  plot_ly(values = ~PI, labels = ~PIDept, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = T)
#totaluser_dept$sizingPolicy$padding <- "0"
#saveWidget(totalpi_dept, file="totalpi_dept.html")

pideptusage <- daily %>%
  group_by(PIDept) %>%
  summarize(Total=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)),User=sum(n_distinct(Name)))
userdeptusage <- daily %>%
  group_by(Department) %>%
  summarize(Total=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)),User=sum(n_distinct(Name)))

#hc <- highchart(type = "stock") %>% 
#  hc_add_series(sujobs$SerialJ, 
#                type = "line",
#                color = "green")
#saveWidget(hc, file="highchart.html")

#sujobs %>% select(Month,Serial,SMP,Multi) %>% pivot_longer(Serial:Multi,names_to="Job",values_to="SUs") %>%
#  hchart(.,"area", stacking = "normal", hcaes(x = Month, y = SUs, group = Job)) -> hc
#saveWidget(hc, file="monthlysushc.html")

#sujobs %>% select(Month,Serial=SerialJ,SMP=SMPJ,Multi=MultiJ) %>% pivot_longer(Serial:Multi,names_to="Job",values_to="Count") %>%
#  hchart(.,"area",hcaes(x = Month, y = "Count", group = Job)) -> hc
#saveWidget(hc, file="monthlyjobshc.html")

daily %>%
  group_by(Month=floor_date(as.Date(Day),"month"),PIDept,Department) %>% 
  summarize(Total=sum(as.double(Total))) -> piusage
#piusage %>%
#  hchart(., "bar", hcaes(x=PIDept, y=Total, group=Year) ) -> hc
#saveWidget(hc,file='pipie.html')
hc <- plot_ly(pideptusage, x = ~Total, y = ~reorder(PIDept, Total), type = "bar", name = "Usage by PI", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = "PI's Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='pideptusage.html')

hc <- plot_ly(pideptusage, x = ~Jobs, y = ~reorder(PIDept, Total), type = "bar", name = "Jobs by PI", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log'), 
     yaxis = list(title = "PI's Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='pideptjobs.html')

hc <- plot_ly(pideptusage, x = ~User, y = ~reorder(PIDept, Total), type = "bar", name = "Users by PI", orientation = 'h') %>%
  layout(xaxis = list(title = ''), 
     yaxis = list(title = "PI's Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='pideptuser.html')

hc <- plot_ly(userdeptusage, x = ~Total, y = ~reorder(Department, Total), type = "bar", name = "Usage by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = "User's Major/Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userdeptusage.html')

hc <- plot_ly(userdeptusage, x = ~Jobs, y = ~reorder(Department, Total), type = "bar", name = "Jobs by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = "User's Major/Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userdeptjobs.html')

hc <- plot_ly(userdeptusage, x = ~User, y = ~reorder(Department, Total), type = "bar", name = "Users by Department", orientation = 'h') %>%
  layout(xaxis = list(title = '' ), 
     yaxis = list(title = "Major/Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userdeptnum.html')

# Get Number of Users by Status
hc <- daily %>% group_by(Status) %>% 
  summarize(Total=round(sum(as.double(Total)),2),User=n_distinct(Name),Jobs=round(sum(as.double(TotalJ)))) %>% filter(Total > 1) %>%
  plot_ly(x = ~User, y = ~Status, type = 'bar', name = "Number of Users", orientation = 'h') %>%
  layout(xaxis = list(title = ''), 
     yaxis = list(title = '' ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userstatusnum.html') 

# Get Usage by Status
hc <- daily %>% group_by(Status) %>% 
  summarize(Total=round(sum(as.double(Total)),2),User=n_distinct(Name),Jobs=round(sum(as.double(TotalJ)))) %>% filter(Total > 1) %>%
  plot_ly(x = ~Total, y = ~Status, type = 'bar', name = "Usage by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = '' ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userstatussus.html') 

hc <- daily %>% group_by(Status) %>% 
  summarize(Total=round(sum(as.double(Total)),2),User=n_distinct(Name),Jobs=round(sum(as.double(TotalJ)))) %>% filter(Total > 1) %>%
  plot_ly(x = ~Jobs, y = ~Status, type = 'bar', name = "Jobs by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = '' ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userstatusjobs.html') 

hc <- daily %>% group_by(Status) %>%
  summarize(Total=round(sum(as.double(Total)),2),User=n_distinct(Name),Jobs=round(sum(as.double(TotalJ)))) %>%
  plot_ly()
hc <- hc %>% add_pie(values = ~Total, labels = ~Status, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = T, domain = list(row = 0, column = 0))
hc <- hc %>% add_pie(values = ~User, labels = ~Status, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = T, domain = list(row = 0, column = 1))
hc <- hc %>% add_pie(values = ~Jobs, labels = ~Status, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = T, domain = list(row = 0, column = 2))
hc <- hc %>% layout(title = "Pie Charts with Subplots", showlegend = F,
                      grid=list(rows=1, columns=3),
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>%
             layout(annotations = list(
                      list(x = 0.2 , y = -0.05, text = "SUs Consumed", showarrow = F, xref='paper', yref='paper'),
                      list(x = 0.6 , y = -0.05, text = "Number of Users", showarrow = F, xref='paper', yref='paper'),
                      list(x = 0.8 , y = -0.05, text = "Number of Jobs", showarrow = F, xref='paper', yref='paper'))
                    )
#saveWidget(hc,file='pistatussus.html') 


jobs1617 <- read_delim(file = '../monitor/jobsay1617.csv.gz', delim = ";")
jobs1718 <- read_delim(file = '../monitor/jobsay1718.csv.gz', delim = ";")
jobs1819 <- read_delim(file = '../monitor/jobsalloc1819.csv.gz', delim = ";")
jobs1920 <- read_delim(file = '../monitor/jobsalloc1920.csv.gz', delim = ";")
jobs2021 <- read_delim(file = '../monitor/jobsalloc2021.csv.gz', delim = ";")
jobs2122 <- read_delim(file = '../monitor/jobsalloc.csv.gz', delim = ";")
# rename jobsalloc.csv.gz to jobsalloc2122.csv.gz on Oct 1 and use the following
#jobs2223 <- read_delim(file = '../monitor/jobsalloc.csv.gz', delim = ";")
jobsthismonth <- read_delim(file = '../monitor/jobs-0.csv', delim = ";")
# Add jobs2223 on Oct 1
jobs <- rbind(jobs1617,jobs1718,jobs1819,jobs1920,jobs2021,jobs2122,jobsthismonth)
total <- jobs %>% mutate(SUTime=round(as.numeric(difftime(End,Start,units="hours"))*NCPUS,2)) %>% summarize(SUs=sum(SUTime),Jobs=n())
cpuonly <- jobs %>% filter(!str_detect(Partition,"gpu")) %>% mutate(SUTime=round(as.numeric(difftime(End,Start,units="hours"))*NCPUS,2)) %>% summarize(SUs=sum(SUTime),Jobs=n())
gpuonly <- jobs %>% filter(str_detect(Partition,"gpu")) %>% mutate(SUTime=round(as.numeric(difftime(End,Start,units="hours"))*NCPUS,2)) %>% summarize(SUs=sum(SUTime),Jobs=n())

cpu_gpu_sus <- tribble(
  ~Type, ~SUs,
  "CPU", cpuonly$SUs,
  "GPU", gpuonly$SUs
) %>% 
  plot_ly(values = ~SUs, labels = ~Type, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = F) %>% 
    layout(title = 'CPU Hours consumed: CPU vs GPU')
cpu_gpu_jobs <- tribble(
  ~Type, ~Job,
  "CPU", cpuonly$Jobs,
  "GPU", gpuonly$Jobs
) %>% 
  plot_ly(values = ~Job, labels = ~Type, type = "pie", textposition = 'inside', textinfo = 'label', showlegend = F) %>%
    layout(title = 'Jobs Run: CPU vs GPU')
cpu_gpu_sus$sizingPolicy$padding <- "0"
cpu_gpu_jobs$sizingPolicy$padding <- "0"
saveWidget(cpu_gpu_sus, file="cpu_gpu_sus.html")
saveWidget(cpu_gpu_jobs, file="cpu_gpu_jobs.html")

# AY 16-17
pi1617 <- as.numeric(daily1617 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user1617 <- as.numeric(daily1617 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept1617 <- as.numeric(daily1617 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept1617 <- as.numeric(daily1617 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs1617 <- as.numeric(daily1617 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus1617 <- as.numeric(daily1617 %>% summarize(SUs=sum(as.double(Total))))
# AY 17-18
pi1718 <- as.numeric(daily1718 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user1718 <- as.numeric(daily1718 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept1718 <- as.numeric(daily1718 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept1718 <- as.numeric(daily1718 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs1718 <- as.numeric(daily1718 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus1718 <- as.numeric(daily1718 %>% summarize(SUs=sum(as.double(Total))))
# AY 18-19
pi1819 <- as.numeric(daily1819 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user1819 <- as.numeric(daily1819 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept1819 <- as.numeric(daily1819 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept1819 <- as.numeric(daily1819 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs1819 <- as.numeric(daily1819 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus1819 <- as.numeric(daily1819 %>% summarize(SUs=sum(as.double(Total))))
# AY 19-20
pi1920 <- as.numeric(daily1920 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user1920 <- as.numeric(daily1920 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept1920 <- as.numeric(daily1920 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept1920 <- as.numeric(daily1920 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs1920 <- as.numeric(daily1920 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus1920 <- as.numeric(daily1920 %>% summarize(SUs=sum(as.double(Total))))
# AY 20-21
pi2021 <- as.numeric(daily2021 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user2021 <- as.numeric(daily2021 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept2021 <- as.numeric(daily2021 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept2021 <- as.numeric(daily2021 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs2021 <- as.numeric(daily2021 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus2021 <- as.numeric(daily2021 %>% summarize(SUs=sum(as.double(Total))))
# AY 21-22
pi2122 <- as.numeric(daily2122 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
user2122 <- as.numeric(daily2122 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
pidept2122 <- as.numeric(daily2122 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
dept2122 <- as.numeric(daily2122 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
jobs2122 <- as.numeric(daily2122 %>% summarize(Jobs=sum(as.double(TotalJ))))
sus2122 <- as.numeric(daily2122 %>% summarize(SUs=sum(as.double(Total))))
# AY 22-23
#pi2223 <- as.numeric(daily2223 %>% group_by(PI) %>% summarize(n=n()) %>% tally())
#user2223 <- as.numeric(daily2223 %>% group_by(Name) %>% summarize(n=n()) %>% tally())
#pidept2223 <- as.numeric(daily2223 %>% group_by(PIDept) %>% summarize(n=n()) %>% tally())
#dept2223 <- as.numeric(daily2223 %>% group_by(Department) %>% summarize(n=n()) %>% tally())
#jobs2223 <- as.numeric(daily2223 %>% summarize(Jobs=sum(as.double(TotalJ))))
#sus2223 <- as.numeric(daily2223 %>% summarize(SUs=sum(as.double(Total))))

	
tribble(~Year,~Users,~Department,~PI,~PIDept,~SUs,~Jobs,
  "2016-17",user1617,dept1617,pi1617,pidept1617,sus1617,jobs1617,
  "2017-18",user1718,dept1718,pi1718,pidept1718,sus1718,jobs1718,
  "2018-19",user1819,dept1819,pi1819,pidept1819,sus1819,jobs1819,
  "2019-20",user1920,dept1920,pi1920,pidept1920,sus1920,jobs1920,
  "2020-21",user2021,dept2021,pi2021,pidept2021,sus2021,jobs2021,
  "2021-22",user2122,dept2122,pi2122,pidept2122,sus2122,jobs2122
	 ) -> dailysummary
# Add for 2022-23
#  "2022-23",user2223,dept2223,pi2223,pidept2223,sus2223,jobs2223

annual_summary <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year")) %>%
	summarize(SUs=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)))
pis <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year"),PI) %>%
	summarize(PI=n()) %>%
	tally(n = 'PI')
pidept <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year"),PIDept) %>%
	summarize(PIDept=n()) %>%
	tally(n = 'PIDept')
users <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year"),Name) %>%
	summarize(Users=n()) %>%
	tally(n = 'Users')
dept <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year"),Department) %>%
	summarize(Department=n()) %>%
	tally(n = 'Department')
annual_summary <- left_join(left_join(left_join(left_join(annual_summary,pis),users),pidept),dept)
	
hc <- annual_summary %>% select(c(Year,Users)) %>% 
  plot_ly(x = ~Year, y = ~Users, type = 'bar', name = "Users") %>%
  layout(xaxis = list(title = '' ), yaxis = list(title = 'Number of Users' ))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_numusers.html')

hc <- annual_summary %>% select(c(Year,PI)) %>% 
  plot_ly(x = ~Year, y = ~PI, type = 'bar', name = "PIs") %>%
  layout(xaxis = list(title = '' ), yaxis = list(title = 'Number of PIs' ))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_numpis.html')

hc <- annual_summary %>% select(c(Year,PIDept)) %>%
	plot_ly(x = ~Year, y = ~PIDept, type = 'bar', name = "PI's Department")
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_numpidept.html')

hc <- annual_summary %>% select(c(Year,Department)) %>%
	plot_ly(x = ~Year, y = ~Department, type = 'bar', name = "User's Major/Department")
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_numdept.html')

hc<- annual_summary %>% select(c(Year,SUs)) %>% 
   plot_ly(x = ~Year, y = ~SUs, type = 'bar', name = "SUs consumed") %>%
   layout(xaxis = list(title = '' ), yaxis = list(title = 'CPU Hours consumed' ))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_sus.html')

hc <- annual_summary %>% select(c(Year,Jobs)) %>% 
  plot_ly(x = ~Year, y = ~Jobs, type = 'bar', name = "Total Jobs") %>%
  layout(xaxis = list(title = '' ), yaxis = list(title = 'Total Jobs run' ))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='annual_jobs.html')

dateWindow = c(as.Date("2017-09-01") , today() + 31 )

# Get Daily Power Usage 
dailypower <- read_delim('dailypower.csv', delim=",")  %>% group_by(Date) %>% summarize(Power=sum(Power)/1000, Energy=sum(Energy)/1000)
dailypower1617 <- read_csv('dailypower1617.csv') %>% mutate(Power=Energy/24/1000,Energy=Energy/1000) %>% select(c(Date,Power,Energy))
dailypower <- rbind(dailypower1617,dailypower)
dailypowerusage <- dygraph( xts(cbind(dailypower$Energy), order.by = dailypower$Date)) %>%
  dySeries("V1", label = "Energy", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dyAxis("y", label = "Average Daily Energy consumption (kWh)") %>%
  dyOptions(stackedGraph = FALSE, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE) %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyLegend(width = 400) %>%
  dyRoller(rollPeriod = 14) %>%
  dyEvent("2016-10-01", "Sol launched with 34 nodes, 760 cores", labelLoc = "top") %>% 
  dyEvent("2017-01-19", "34 nodes, 760 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-03-15", "42 nodes, 972 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-05-01", "55 nodes, 1284 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-11-15", "56 nodes, 1300 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-12-01", "56 nodes, 1300 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-04-02", "63 nodes, 1552 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-08-31", "65 nodes, 1624 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-11-12", "66 nodes, 1648 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-12-01", "68 nodes, 1720 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2019-01-02", "80 nodes, 2152 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2019-04-01", "81 nodes, 2188 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-05-31", "85 nodes, 2332 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-08-01", "87 nodes, 2404 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-11-12", "Hawk: User Friendly", labelLoc = "top") %>%
  dyEvent("2021-02-01", "Hawk in Production", labelLoc = "top") %>%
  dyEvent("2022-04-05", "127 nodes, 4404 cores, 181 GPUs", labelLoc = "top") %>%
  dyRangeSelector( dateWindow = dateWindow)
dailypowerusage$sizingPolicy$padding <- "0"
saveWidget(dailypowerusage, file="dailypowerusage.html")

# Get Monthyl Power Usage 
monthlypower <- read_delim('monthlypower.csv', delim=",") %>% group_by(Month) %>% summarize(Power=sum(Power)/1000, Energy=sum(Energy)/1000)
monthlypowerusage <- dygraph( xts(cbind(monthlypower$Power,monthlypower$Energy), order.by = monthlypower$Month)) %>%
  dySeries("V1", label = "Power/kW", color = "blue", stepPlot = TRUE, fillGraph = TRUE) %>%
  dySeries("V2", label = "Energy/MWh", color = "green", stepPlot = TRUE, fillGraph = TRUE, axis = 'y2') %>%
  dyAxis("y", label = "Power/kW") %>%
  dyAxis("y2", label = "Energy (MWh)") %>%
  dyOptions(stackedGraph = FALSE, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE, labelsKMB = TRUE) %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyLegend(width = 400) %>%
  dyRoller(rollPeriod = 1) %>%
  dyEvent("2016-10-01", "Sol launched with 34 nodes, 760 cores", labelLoc = "top") %>% 
  dyEvent("2017-01-19", "34 nodes, 760 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-03-15", "42 nodes, 972 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-05-01", "55 nodes, 1284 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-11-15", "56 nodes, 1300 cores, 50 GPUs", labelLoc = "top") %>%
  dyEvent("2017-12-01", "56 nodes, 1300 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-04-02", "63 nodes, 1552 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-08-31", "65 nodes, 1624 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-11-12", "66 nodes, 1648 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2018-12-01", "68 nodes, 1720 cores, 72 GPUs", labelLoc = "top") %>%
  dyEvent("2019-01-02", "80 nodes, 2152 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2019-04-01", "81 nodes, 2188 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-05-31", "85 nodes, 2332 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-08-01", "87 nodes, 2404 cores, 120 GPUs", labelLoc = "top") %>%
  dyEvent("2020-11-12", "Hawk: User Friendly", labelLoc = "top") %>%
  dyEvent("2021-02-01", "Hawk in Production", labelLoc = "top") %>%
  dyEvent("2022-04-05", "127 nodes, 4404 cores, 181 GPUs", labelLoc = "top") %>%
  dyRangeSelector( dateWindow = dateWindow)
monthlypowerusage$sizingPolicy$padding <- "0"
saveWidget(monthlypowerusage, file="monthlypowerusage.html")

annual_summary <- daily %>%
	group_by(Year=floor_date(as.Date(Day),"year"),PI) %>%
	summarize(SUs=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)))

annual_summary %>% knitr::kable()


