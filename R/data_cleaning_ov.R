#Does not work, SAS data files are password portected
#setwd("C:/Users/Lenovo/Documents/svenka_data/Other_data/CD1/")

#install.packages("sas7bdat")
#library(sas7bdat)

#hemmalign_can <- read.sas7bdat("hemmalign_can.sas7bdat")
install.packages("gdata")
library(gdata)
brot  <- read.xls("BrotICDkodar.xlsx",sheet=1)


dx <- c("201",  "2001", "MGUS", "AMYL", "2022", "KLL", "203",  "2040", "2000", "2021", "LPL",  "2024", "WM",   
        "2044", "2049", "2020", "2047", "2046")

stuff <- getCC(dx,wd="C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/")


load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/sv.RData")
load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/ov.RData")
write.table(sv,"C:/Users/Lenovo/Documents/svenska_data/G�gn_csv_format/ov.csv", col.names = T)
load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/cases.RData")
load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/controls.RData")
load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/can.RData")
load("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/dors.RData")
source("C:/Users/Lenovo/Documents/svenska_data/G�gnS�m/functions_swedata.R")


#Locate those records with no indatuma date. 15269 Hafa enga INDATUMA e�a engan innkomudagsetningu
 ov %>% filter(is.na(INDATUMA) | INDATUMA == "") %>% summarise(n())
 ov %>% filter(is.na(INDATUM) | INDATUM == "") %>% summarise(n())
 #H�rna er enginn �n LopNr
 ov %>% filter(is.na(LopNr) | LopNr == "") %>% summarise(n())
 #12601 have incomplete dates
 ov %>% filter(nchar(INDATUMA) < 8 & !is.na(INDATUMA)) %>% group_by(nchar(INDATUMA)) %>% summarize(n())
 # A tibble: 7 x 2
# `nchar(INDATUMA)` `n()`
# <int> <int>
#   1                 0 15269
# 2                 1    15
# 3                 3    18
# 4                 4 12559
# 5                 5     1
# 6                 6     1
# 7                 7     7
ov %>% filter(nchar(INDATUMA) == 1 ) #INDATUM er t�mt og INDATUMA = ".", ekkert h�gt a� giska � dagsetningu => henda/�noth�ft
ov %>% filter(nchar(INDATUMA) == 3 ) #INDATUM er t�mt og INDATUMA hefur 3 stafi t.d. 101, ekkert h�gt a� giska � dagsetningu => henda/�noth�ft
ov %>% filter(nchar(INDATUMA) == 4 ) %>% tbl_df #INDATUMA hefur bara �r, � INDATUMA hefur veri� b�in til dagtning sem mi�dagur �rsins

#Breyti formatti � INTDATUM date
ov %>% mutate(INDATUM = as.Date(INDATUM)) -> ov_clean
table(is.na(ov_clean$ALDER))
#34 missing age

# sv %>% filter(is.na(INDATUMA) | (INDATUM == "" & UTDATUM == "")) %>% summarise(n())
# sv %>% filter(is.na(INDATUMA) | !(INDATUMA == "" & UTDATUM == "")) %>% summarise(n())
# sv %>% filter(is.na(INDATUMA) | !(INDATUM == "" & UTDATUM == "")) -> sv_clean 
# 
# #fjarl�ga �� sem hafa ekkert lopNr, svo vir�ist sem d�lkar hafa f�rst til 
# sv_clean %>% filter(LopNr != "") -> sv_clean
# #�� eru allir �n UTDATUM fjarl�g�ir
# sv_clean %>% mutate() 
# 
# #Breyta formatti � Alder � numeric, replace t�mum gildum � INDATUM og INDATUMA sem h�f�u "" � NA
# sv_clean %>% mutate(ALDER = as.numeric(ALDER),INDATUM = replace(INDATUM, INDATUM == "",NA),INDATUMA = replace(INDATUMA, INDATUMA == "",NA)) -> sv_clean
# 
# #Breyta fromatti � INDATUM � date �r chr
# sv_clean %>% mutate(INDATUM = as.Date(INDATUMA,"%Y%m%d"),UTDATUM = as.Date(UTDATUMA,"%Y%m%d")) -> sv_clean
# 
# sv_clean %>% filter(is.na(INDATUM) ) %>% arrange(desc(UTDATUM)) %>% tbl_df
# sv_clean %>% filter(is.na(INDATUMA) ) %>% summarise(n())
# #1492 vantar indag, en �au eru �� �ll me� �tdag. 
# sv_clean %>% filter(is.na(INDATUMA) ) %>% select(LopNr) -> noindate
# cases %>% filter((Lopnr_fall %in% noindate$LopNr)) # 152 af �eim eru skr�� sem cases
# table(duplicated(noindate$LopNr)) #1321 einstaklingar vantar indatum, svo sumir birtast oftar en einu sinni
# table(group_size(group_by(noindate,LopNr)))
# #Fj�ldi ra�a � einstakling, td. eru 120 einstaklingar me� 2 ra�ir. 
# #   1    2    3    4    5 
# #1178  120   19    3    1 
# #�ar sem �etta eru ekki �a� margir �� legg �g til a� henda �eim �llum
# 
# #sko�a �� sem eru ekki me� fullkomna dagsetningu, 1651
# sv_clean %>% filter(nchar(INDATUMA) < 8 & !is.na(INDATUMA)) %>% summarize(n())
# #dagsetningar eru allt ni�ur � 2 stafi, 250 records
# #Elsta sl�k skr� er fr� 1970 yngst 1985, �.e. �tdag
# #Af �essum 250 eru 244 bara me� �r � utdatum, 6 me� fullskr�� utdatum
# # A tibble: 4 x 2
# #`nchar(INDATUMA)` `n()`
# #<int> <int>
# #1                 2   250
# #2                 4   631
# #3                 6   738
# #4                 7    32
# sv_clean %>% filter(nchar(INDATUMA) < 8 & !is.na(INDATUMA)) %>% group_by(nchar(INDATUMA)) %>% summarize(n())
# 
# sv_clean %>% filter(nchar(INDATUMA) == 2 ) %>% summarize(min(UTDATUMA),max(UTDATUMA),n())
# sv_clean %>% filter(nchar(INDATUMA) == 2 ) %>% group_by(nchar(UTDATUMA)) %>% summarize(n())
# sv_clean %>% filter( (nchar(INDATUMA) == 2 & nchar(UTDATUMA) == 4)  ) %>% summarize(n())##henda �t
# sv_clean %>% filter( !(nchar(INDATUMA) == 2 & nchar(UTDATUMA) == 4) | is.na(UTDATUMA) | is.na(INDATUMA) ) -> sv_clean ##hendi �� ekki �t t�mum gildum
# 
# 
# sv_clean %>% filter(nchar(INDATUMA) == 2 ) %>% tbl_df
# 
# #4479 individuals have incomplete UTDATUMA
# sv_clean %>% filter(nchar(UTDATUMA) < 8 & !is.na(UTDATUMA)) %>% group_by(nchar(UTDATUMA)) %>% summarize(n())
# 
# #UTDATUM � undan Indatum, 1357 ra�ir
# sv_clean %>% filter((UTDATUM - INDATUM) < 0) %>% summarize(n())
# sv_clean %>% filter((UTDATUM - INDATUM) < 0) %>% summarise(mean(UTDATUM - INDATUM,na.rm=T), sd(UTDATUM - INDATUM,na.rm=T), min(UTDATUM - INDATUM,na.rm=T),max(UTDATUM - INDATUM,na.rm=T) )
# 
# #innlagnat�mi fer upp � 29630 days. 16168 me� yfir 1000 daga innl�gn. �etta er lang l�klegast allt r�ng skr�ning
# sv_clean %>% mutate(INN = (UTDATUM - INDATUM) ) %>% summarise(mean(INN,na.rm=T), sd(INN,na.rm=T), min(INN,na.rm=T),max(INN,na.rm=T) )
# sv_clean %>% mutate(INN = (UTDATUM - INDATUM) ) %>% filter(INN > 1000) %>% summarise(n())
# sv_clean %>% mutate(INN = (UTDATUM - INDATUM) ) %>% filter(INN > 1000) %>% arrange(desc(UTDATUM)) %>% tbl_df
# 
# sv_clean %>%  filter(LopNr == "2963534")  %>% mutate(INN = (UTDATUM - INDATUM) ) %>% select(LopNr,DIAGNOS,INDATUM,UTDATUM,INN) 
# 
# sv_clean %>% filter(nchar(INDATUMA) == 4) %>% tbl_df
# sv_clean %>% filter(OP == "")
# 
# ###Locate those with no Alder (AGE) variable
# sv_clean %>% mutate(ALDER = as.numeric(ALDER)) -> sv_clean
# sv_clean %>% mutate(LopNr = strtoi(LopNr)) -> sv_clean
# 
# sv_clean %>% filter(is.na(ALDER) ) %>% summarise(n())
# #508 individuals are missing age. 
# sv_clean %>% filter(is.na(ALDER) & is.na(ALDER_S)) %>% 
# #They though all have Alder_S. The differance is at most 1 year with mean=0.48
# #I will replace the empty ALGER with ALDER_S  
# sv_clean %>% filter(LopNr == 2208393)
# sv_clean %>% filter(LopNr == 443494)
# 
# sv_clean %>%  mutate(ALDER = ifelse(is.na(ALDER),ALDER_S,ALDER)) -> sv_clean
# 
# table(sv_clean$HDIA == "",sv_clean$DIAGNOS == "")
# #210389 individuals are missing both HDIA and DIAGNOS. Maybe we can impute/predict these values but I don't think it makes sense 


