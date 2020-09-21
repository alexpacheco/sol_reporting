library(tidyverse)
library(lubridate)
library(dygraphs)
library(xts)
library(htmlwidgets)
library(highcharter)
library(plotly)
library(ggplot2)

data <- read.table('/home/alp514/usage/daily.csv', header = FALSE, sep = ",", col.names = paste0("V",seq_len(25)), fill = TRUE)
data[is.na(data)] <- 0

daily1617 <- read_delim('soldaily1617.csv', delim=";")
daily1718 <- read_delim('soldaily1718.csv', delim=";")
daily1819 <- read_delim('soldaily1819.csv', delim=";")
daily1920 <- read_delim('soldaily1920.csv', delim=";")
ay1617su <- c(580320.00,561600.00,580320.00,580320.00,524160.00,580320.00,699840.00,955296.00,924480.00,955296.00,955296.00,924480.00)
ay1718su <- c(955296.00,924480.00,967200.00,967200.00,873600.00,967200.00,1117440.00,  1154688.00,1117440.00,1154688.00,1155480.00,1169280.00)
ay1819su <- c(1624*31,1696*30,1720*31,2152*31,2152*28,2152*31,2188*30,2188*31,2188*30,2188*31,2188*31,2188*30)*24
ay1920su <- c(2188*31,2188*30,2188*31,2188*31,2188*29,2188*31,2188*30,2188*31,2332*30,2332*31,2404*31,2404*30)*24

daily <- rbind(daily1617,daily1718,daily1819,daily1920)
aysu <- c(ay1617su,ay1718su,ay1819su,ay1920su)

# Create daily vector
aymonth<- seq(as.Date("2016-10-01"), today(), by = "month")
AYSU <- tibble(Month=aymonth,Available=aysu)
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
  dyRangeSelector( dateWindow = dateWindow)
monthlyusage$sizingPolicy$padding <- "0"
saveWidget(monthlyusage, file="monthlyusage.html")

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
  summarize(Total=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)))
userusage <- daily %>%
  group_by(Department) %>%
  summarize(Total=sum(as.double(Total)),Jobs=sum(as.double(TotalJ)))

hc <- highchart(type = "stock") %>% 
  hc_add_series(sujobs$SerialJ, 
                type = "line",
                color = "green")
#saveWidget(hc, file="highchart.html")

sujobs %>% select(Month,Serial,SMP,Multi) %>% pivot_longer(Serial:Multi,names_to="Job",values_to="SUs") %>%
  hchart(.,"area", stacking = "normal", hcaes(x = Month, y = SUs, group = Job)) -> hc
#saveWidget(hc, file="monthlysushc.html")

sujobs %>% select(Month,Serial=SerialJ,SMP=SMPJ,Multi=MultiJ) %>% pivot_longer(Serial:Multi,names_to="Job",values_to="Count") %>%
  hchart(.,"area",hcaes(x = Month, y = "Count", group = Job)) -> hc
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

hc <- plot_ly(userusage, x = ~Total, y = ~reorder(Department, Total), type = "bar", name = "Usage by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = "User's Major/Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userdeptusage.html')
hc <- plot_ly(userusage, x = ~Jobs, y = ~reorder(Department, Total), type = "bar", name = "Jobs by User", orientation = 'h') %>%
  layout(xaxis = list(title = '', type = 'log' ), 
     yaxis = list(title = "User's Major/Department" ),
     margin = list(l = 200, r = 20, t = 25, b = 25))
hc$sizingPolicy$padding <- "0"
saveWidget(hc,file='userdeptjobs.html')

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
  aummarize(Total=round(sum(as.double(Total)),2),User=n_distinct(Name),Jobs=round(sum(as.double(TotalJ)))) %>% filter(Total > 1) %>%
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
