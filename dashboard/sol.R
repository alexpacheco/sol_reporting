suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(lubridate)))

read_delim("tmp.csv",delim=",", col_names = c("Time","Partition","Host","Value")) -> watts

dailywatts <- watts %>% group_by(Day=floor_date(as.Date(Time), "day"),Partition,Host) %>% summarize(Power=round(mean(Value),2),Energy=round(Power*24,2))

dailywatts %>% write_csv("dailypower.csv",append=TRUE)

read_csv("dailypower.csv") -> dailywatts

monthlywatts <- dailywatts %>% group_by(Month=floor_date(as.Date(Date), "month"),Partition,Host) %>% summarize(Power=round(mean(Power),2),Energy=round(sum(Energy)/1000,2))

monthlywatts %>% write_csv("monthlypower.csv")

#dailywatts %>% filter(Date >= as.Date("2017-10-01") & Date < as.Date("2018-10-01")) %>% write_csv("dailypower1718.csv")
#monthlywatts %>% filter(Month >= as.Date("2017-10-01") & Month < as.Date("2018-10-01") ) %>% write_csv("monthlypower1718.csv")
#dailywatts %>% filter(Date >= as.Date("2018-10-01") & Date < as.Date("2019-10-01")) %>% write_csv("dailypower1819.csv")
#monthlywatts %>% filter(Month >= as.Date("2018-10-01") & Month < as.Date("2019-10-01") ) %>% write_csv("monthlypower1819.csv")
#dailywatts %>% filter(Date >= as.Date("2019-10-01") & Date < as.Date("2020-10-01")) %>% write_csv("dailypower1920.csv")
#monthlywatts %>% filter(Month >= as.Date("2019-10-01") & Month < as.Date("2020-10-01") ) %>% write_csv("monthlypower1920.csv")
#dailywatts %>% filter(Date >= as.Date("2020-10-01") & Date < as.Date("2021-10-01")) %>% write_csv("dailypower2021.csv")
#monthlywatts %>% filter(Month >= as.Date("2020-10-01") & Month < as.Date("2021-10-01")) %>% write_csv("monthlypower2021.csv")
dailywatts %>% filter(Date >= as.Date("2021-10-01") & Date < as.Date("2022-10-01")) %>% write_csv("dailypower2122.csv")
monthlywatts %>% filter(Month >= as.Date("2021-10-01") & Month < as.Date("2022-10-01")) %>% write_csv("monthlypower2122.csv")




