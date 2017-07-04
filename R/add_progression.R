#'
#'
#'
#'
#'
#'
#'

add_progression <- function(part_data,dx,wd=getwd()){
  #setting the original wd
  or_wd <- getwd()

  #Now setting to preferred wd
  setwd(wd)

  #Retrieving the cases dataset from where progression data will be extracted
  load("cases.RData")

  progression_data <- data.frame(lop_nr=part_data$lop_nr)

  for(i in 1:length(dx)){
    temp <- filter(cases,Dia == dx[i])
    progression_data[,i+1] <- temp$DIADAT[match(part_data$lop_nr,temp$Lopnr_fall)]
    names(progression_data)[i+1] = paste("progression_",dx[i],sep="")
  }


  #Resetting to original wd
  setwd(or_wd)

  return(bind_cols(part_data,progression_data[2:ncol(progression_data)]))
}
