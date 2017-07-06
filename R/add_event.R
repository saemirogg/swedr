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
                      cancer=F){

  #If the search is in the cancer registry(cancer==T)
  # Sölvi: Need to throw error if dia_data is not from the cancer registry
  if(cancer){
    dia_data <- select(dia_data,lop_nr=LopNr,INDATUMA=DIADAT,ICDO10,ICD9,ICD7,ICDO3) %>%
      mutate(DIAGNOS=paste(ICDO10,ICD7,ICD9,ICDO3))
  }

  #If dx is not put in as a fully formated regex query we make it formated.
  # Sölvi: Consider removing if(length(dx)>1), since paste works fine on vectors of length equal to 1. Note that this does not work for
  #length(dx)==1 since the spacing is not provided
  if(length(dx)>1){
    dx <- paste(" ",paste(dx,collapse="| "),sep="")
    #Sölvi: If there is only one code then length(dx)==1 and thus this is not needed
  }else if(!grepl("|",dx) & length(dx) == 1) {
    paste(" ",gsub(" ","",dx),sep="")#If the there is only one code for a variable it is formatted correctly by this clause
  }else{
    stop("dx is of length 0")
  }


  #Adding a " " in front of first diagnosis to be able to search with grepl
  dia_data$DIAGNOS <- paste(" ",dia_data$DIAGNOS,sep="")

  #pulling out only relevant rows of dia_data to speed up later analysis
  dia_data <- filter(dia_data,grepl(dx,DIAGNOS))

  #Adding inclusion date and time from inclusion date of the diagnosis
  dia_data$incl_date <- part_data$incl_date[match(dia_data$lop_nr,part_data$lop_nr)]
  dia_data$time_from_incl <- days_diff(dia_data$incl_date,dia_data$INDATUMA)


  #if first, we will find the first diagnosis of dx within the dataset
  dia_data <- filter(dia_data,(time_from_incl > before_time[1] & time_from_incl < before_time[2]) | (time_from_incl > after_time[1] & time_from_incl < after_time[2]))  %>%
    group_by(lop_nr) %>%

  if(relationship=="first"){
    filter(INDATUMA==min(INDATUMA))
  }else if(relationship=="closest"){
    filter(time_from_incl==min(abs(time_from_incl)))
  }else if(relationship=="last"){
    filter(INDATUMA==max(INDATUMA))
  }else{
    stop("Relationship provided (",relationship,") is not recognized")
  }
  #Now creating a vector of the INDATUMA for those with diagnosis and NA if no diagnosis.
  date_of_diagnosis <- dia_data$INDATUMA[match(part_data$lop_nr,dia_data$lop_nr)]

  return(date_of_diagnosis)

}
