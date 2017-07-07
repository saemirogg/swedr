#'
#'
#'
#'
#'
#'
#'

verify_cancer <- function(data,
                          dx,wd=getwd()){
  #load the data
  setwd(wd)
  load("can.RData")

  dx <- paste(dx,collapse="|")

  ##Subsetting the data to only cancer diagnoses of interest
  ##There is something wrong with this filter call,
  ## The statement DIADAT > min(data$incl_date)+10000 does not make any sense
  can <- filter(can,
                grepl(dx,ICD7) | grepl(dx,ICD9) | grepl(dx,ICDO10),
                DIADAT > min(data$incl_date)+10000) #laggtime for the cancer registry. set here at 1 year check3
  #Adding verified column to data
  #Sölvi: swapped the order of these two lines in order for cases_data to include verified as a col
  data$verified <- data$lop_nr %in% can$LopNr

  #Taking out cases that are not recorded in the cancer registry
  #Sölvi: changed data$lop_nr %in% can$LopNr to verified
  cases_data <- filter(data,verified)

  #Loading the control dataset to exclude controls not associated with verified cancer diagnoses
  #Sölvi: I suggest not loading this dataset, but to extract the controls from data and reomve
  #those that correspond to the cases not recorded from the cancer registry. In effect
  #we need to change getCC s.t one more column is added, namely Lopnr_fall.
  load("controls.RData")

  #Creating subset with only these controls
  control_group_data <- filter(controls,Lopnr_fall %in% cases_data$lop_nr)
  control_group_data <- filter(controls,Lopnr_fall %in% cases_data$lop_nr)

  control_data <- filter(data,lop_nr %in% control_group_data$Lopnr_kontroll)

  #Giving data on the verification process
  warning(sum(data$case==T & data$verified==F),"(",round(sum(data$case==T & data$verified==F)/sum(data$case),digits = 2)*100,"%) cases are not in the cancer registry. They and their corresponding ",sum(!data$case)-nrow(control_data)," controls have been removed \n",
          "There are ",sum(!(unique(can$LopNr) %in% data$lop_nr))," diagnoses in the cancer registry that are not in the cases register (laggtime included)\n",
          "There are ",sum(data$case==F & data$verified==T)," controls that have a diagnosis of the given cancer")

  return(rbind(cases_data,control_data)) # %>% distinct(lopnr,.keep_all=T)
}
