#'
#'
#'
#'
#'
#'
#'

verify_cancer <- function(data,
                          dx){
  #load the data
  load("can.RData")

  dx <- paste(dx,collapse="|")

  ##Subsetting the data to only cancer diagnoses of interest
  can <- filter(can,
                grepl(dx,ICD7) | grepl(dx,ICD9) | grepl(dx,ICDO10),
                DIADAT > min(data$incl_date)+10000) #laggtime for the cancer registry. set here at 1 year check3
  #Taking out cases that are not recorded in the cancer registry
  cases_data <- filter(data,lop_nr %in% can$LopNr)

  #Adding verified column to data
  data$verified <- data$lop_nr %in% can$LopNr

  #Loading the control dataset to exclude controls not associated tih verified cancer diagnoses
  load("controls.RData")

  #Creating subset with only these controls
  control_group_data <- filter(controls,Lopnr_fall %in% cases_data$lop_nr)

  control_data <- filter(data,lop_nr %in% control_group_data$Lopnr_kontroll)

  #Giving data on the verification process
  warning(sum(data$case==T & data$verified==F),"(",round(sum(data$case==T & data$verified==F)/sum(data$case),digits = 2)*100,"%) cases are not in the cancer registry. They and their corresponding ",sum(!data$case)-nrow(control_data)," controls have been removed \n",
          "There are ",sum(!(unique(can$LopNr) %in% data$lop_nr))," diagnoses in the cancer registry that are not in the cases register (laggtime included)\n",
          "There are ",sum(data$case==F & data$verified==T)," controls that have a diagnosis of the given cancer")

  return(rbind(cases_data,control_data))
}
