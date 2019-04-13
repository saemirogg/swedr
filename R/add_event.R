#'
#'
#'
#'
#'

add_event <- function(dx,
                      part_data,
                      dia_data,
                      relationship="first",
                      before_time=c(-Inf,0),
                      after_time=c(0,Inf),
                      cancer=F,
                      exclude_outside=F,
                      ignore=F){

  #If the search is in the cancer registry(cancer==T)
  # Sölvi: Need to throw error if dia_data is not from the cancer registry
  if(cancer){
    dia_data <- select(dia_data,lop_nr=LopNr,INDATUMA=DIADAT,ICDO10,ICD9,ICD7,ICDO3) %>%
      mutate(DIAGNOS=paste(ICDO10,ICD7,ICD9,ICDO3))
  }

  #If dx is not put in as a fully formated regex query we make it formated.
  # Sölvi: Changed the logic, removing a condition in the else if statement. Now nothing is
  # done if dx is formatted correctly
  if(length(dx)>1){
    dx <- paste(" ",paste(dx,collapse="| "),sep="")
  }else if(!grepl("|",dx)) {
    paste(" ",gsub(" ","",dx),sep="")#If the there is only one code for a variable it is formatted correctly by this clause
  }


  #Adding a " " in front of first diagnosis to be able to search with grepl
  dia_data$DIAGNOS <- paste(" ",dia_data$DIAGNOS,sep="")

  #pulling out only relevant rows of dia_data to speed up later analysis
  if(ignore==F){
    dia_data <- filter(dia_data,grepl(dx,DIAGNOS))
  }else{
    dia_data <- filter(dia_data,!grepl(dx,DIAGNOS))
  }

  #Adding inclusion date and time from inclusion date of the diagnosis
  dia_data$incl_date <- part_data$incl_date[match(dia_data$lop_nr,part_data$lop_nr)]
  dia_data$time_from_incl <- days_diff(dia_data$incl_date,dia_data$INDATUMA)
  
  #We have had occational errors with the before_time and after_time being character variables. Therefore we change it now to numeric vectors.
  before_time <- as.numeric(before_time)
  after_time <- as.numeric(after_time)

  #if exclusion is chosen as T then we will find those that have the diagnoses outside the timelimits provided and exclude them.
  #We start by marking those that this applies to
  if(exclude_outside==T){
    exclude_dia_data <- filter(dia_data,(time_from_incl <= before_time[1] | time_from_incl >= before_time[2]) & (time_from_incl <= after_time[1] | time_from_incl >= after_time[2]))
    part_data$exclude <- part_data$lop_nr %in% exclude_dia_data$lop_nr
  }

  #if first, we will find the first diagnosis of dx within the dataset
  dia_data <- filter(dia_data,(time_from_incl >= before_time[1] & time_from_incl <= before_time[2]) | (time_from_incl >= after_time[1] & time_from_incl <= after_time[2]))  %>%
    group_by(lop_nr)

  if(relationship=="first"){
    dia_data <- slice(dia_data,which.min(INDATUMA))
  }else if(relationship=="closest"){
    dia_data <- slice(dia_data,which.min(abs(time_from_incl)))
  }else if(relationship=="last"){
    dia_data <- slice(dia_data,which.max(INDATUMA))
  }else{
    stop("Relationship provided (",relationship,") is not recognized")
  }
  #Now creating a vector of the INDATUMA for those with diagnosis and NA if no diagnosis.
  part_data$date_of_diagnosis <- dia_data$INDATUMA[match(part_data$lop_nr,dia_data$lop_nr)]

  #if excluding those with diagnoses outside the number 0 is put instead of NA or the date in the date of diagnosis
  if(exclude_outside==T){
    part_data$date_of_diagnosis <- ifelse(part_data$exclude,0,part_data$date_of_diagnosis)
  }

  return(part_data$date_of_diagnosis)

}
