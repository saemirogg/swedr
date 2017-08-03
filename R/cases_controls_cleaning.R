library(dplyr)
load("C:/Users/Lenovo/Documents/svenska_data/GögnSæm/cases.RData")
load("C:/Users/Lenovo/Documents/svenska_data/GögnSæm/controls.RData")

controls %>% left_join(cases,by="Lopnr_fall") -> cases_controls

cases_controls %>% filter(KON.x != KON.y) %>% distinct(Lopnr_fall) -> Diff_sex

sv[(sv$LopNr %in% Diff_sex$Lopnr_fall), ]
#LopNr AterPNr ALDER ALDER_S   AR    DIAGNOS   HDIA    INDATUM INDATUMA KON MVO   OP SJUKHUS    UTDATUM UTDATUMA   LK
#10497788 878442       0    61      61 1973 824,10 591 824,10 1973-12-17 19731217   1 301 8200   11011 1973-12-20 19731220 0181

load("C:/Users/Lenovo/Documents/svenska_data/GögnSæm/ov.RData")
ov[(ov$LopNr %in% Diff_sex$Lopnr_fall), ]
#[1] LopNr    AterPNr  ALDER    ALDER_S  AR       DIAGNOS  HDIA     INDATUM  INDATUMA KON      MVO      OP       SJUKHUS  LK      
#<0 rows> (or 0-length row.names)


load("C:/Users/Lenovo/Documents/svenska_data/GögnSæm/dors.RData")
dors[(dors$LopNr %in% Diff_sex$Lopnr_fall), ]
#Hérna eru þeir báðir skráðir sem karlmenn. Það hlýtur að vera rétt. 

controls %>% mutate(KON = ifelse(Lopnr_fall %in% Diff_sex$Lopnr_fall,1,KON)) -> controls
cases %>% mutate(KON = ifelse(Lopnr_fall %in% Diff_sex$Lopnr_fall,1,KON)) -> cases

write.table(controls, file = "C:/Users/Lenovo/Documents/svenska_data/Gögn_csv_format/controls_clean.csv")
write.table(cases, file = "C:/Users/Lenovo/Documents/svenska_data/Gögn_csv_format/cases_clean.csv")

