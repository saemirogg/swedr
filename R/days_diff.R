#'
#'
#'
#'
#'
#'

days_diff <- function(time1,time2){

  return(as.numeric(as.Date(as.character(time2),format="%Y%m%d")-as.Date(as.character(time1),format="%Y%m%d")))


}
