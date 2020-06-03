module load r-project/3.3.3
unset R_LIBS
Rscript -e "library(tidyverse); library(knitr) ; as_tibble(installed.packages(.Library) ) %>% select(c(Package,Version)) %>% write_csv('r333.csv')"
module unload r-project/3.3.3

module load r-project/3.4.2
unset R_LIBS
Rscript -e "library(tidyverse); library(knitr) ; as_tibble(installed.packages(.Library) ) %>% select(c(Package,Version)) %>% write_csv('r342.csv')"
module unload r-project/3.4.2

module load anaconda/python3
unset R_LIBS
Rscript -e "library(tidyverse); library(knitr) ; as_tibble(installed.packages(.Library) ) %>% select(c(Package,Version)) %>% write_csv('r343.csv')"
module unload anaconda/python3

module load r-project/3.5.3
unset R_LIBS
Rscript -e "library(tidyverse); library(knitr) ; as_tibble(installed.packages(.Library) ) %>% select(c(Package,Version)) %>% write_csv('r353.csv')"

sed -i -e 's/Version/3.3.3/g' r333.csv
sed -i -e 's/Version/3.4.2/g' r342.csv
sed -i -e 's/Version/3.4.3/g' r343.csv
sed -i -e 's/Version/3.5.3/g' r353.csv

Rscript -e "library(tidyverse); library(knitr) ; \
   r333 <- read_csv('r333.csv'); \
   r342 <- read_csv('r342.csv') ; \
   r343 <- read_csv('r343.csv') ; \
   r353 <- read_csv('r353.csv') ; \
   full_join(full_join(full_join(r333,r342,by='Package'),r343,by='Package'),r353,by='Package') -> tmp; \
   tmp[is.na(tmp)] <- '' ; \
   tmp %>% arrange(Package) %>% kable()"

module unload r-project/3.5.3
