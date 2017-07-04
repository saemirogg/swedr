#'
#'
#'
#'
#'
library(dplyr)
library(tidyr)

get_CC <- function(dx,
                  year1=0,
                  year2=20140101,
                  incl_controls=T,
                  wd=getwd()){
  #Saving the original wd and setting a new one
  or_wd <- getwd()
  setwd(wd)

  #getting data for cases and controls
  load("cases.RData")
  load("controls.RData")

  #Creating subset with cases of the given diagnoses
  case_group <- filter(cases,Dia %in% dx,DIADAT > year1,DIADAT < year2) %>%
    mutate(YOB=controls$FoddAr_fall[match(Lopnr_fall,controls$Lopnr_fall)],
           sex = factor(KON,labels=c("Male","Female")),#Changing sex to M/F instead of 1 and 2
           lop_nr=Lopnr_fall,
           case=T,
           incl_date=DIADAT,
           age=round(incl_date/10000,digits = 0)-YOB
    ) %>%
    select(lop_nr,case,sex,YOB,incl_date)

  #If incl_controls is F then to be able to add no controls we need an empty data.frame
  control_group <- data.frame(LopNr=NULL,SEX=NULL,CASE=NULL,YOB=NULL,InclDate=NULL)

  #Creating data for controls.
  if(incl_controls==T){
    control_group <- filter(controls,Lopnr_fall %in% case_group$lop_nr) %>%
      mutate(incl_date=case_group$incl_date[match(Lopnr_fall,case_group$lop_nr)],
             YOB=FoddAr_kontroll,
             sex=factor(KON,labels=c("Male","Female")),
             lop_nr=Lopnr_kontroll,
             case=F,
             age = round(incl_date/10000,digits = 0)-YOB
      )%>%
      select(lop_nr,case,sex,YOB,incl_date)
  }

  #Joining the two datasets and excluding cases that are also controls and only using individuals as controls once check2
  cases_and_controls <- bind_rows(case_group,control_group)%>%
    group_by(lop_nr) %>%
    filter(case==max(case)) %>% #if repeated individuals are case and control then include the case
    ungroup()%>%
    group_by(lop_nr) %>%
    filter(incl_date==min(incl_date)) #if repeated individuals are of the same case/control status then use earliest incl_date

  #Creating time of death or loss to follow-up at end of the study period
  #Loading the death registry and subsetting it for the subset in question
  load("dors.RData")
  codr <- filter(dors,LopNr %in% cases_and_controls$lop_nr)

  #Putting in death or loss to followup dates
  cases_and_controls$death_date <- codr$DODSDAT[match(cases_and_controls$lop_nr,codr$LopNr)] #entering date of death.
  cases_and_controls$FU <-  ifelse(is.na(cases_and_controls$death_date),year2,NA) #if not death follow up time is determined at 2014 when the scope of the data ends.

  #setting wd to original wd
  setwd(or_wd)

  #return the data.set
  return(as.data.frame(cases_and_controls))

}
