#'
#'
#'
#'
#'
#'
#'

extract_death <- function(dataset,incl_COD=F){

  dataset <- mutate(dataset, death=!is.na(death_date),
                    last_day_deathFU = pmax(death_date,FU,na.rm=T),
                    time_to_deathFU = as.numeric(as.Date(as.character(last_day_deathFU),format="%Y%m%d")-as.Date(as.character(incl_date),format="%Y%m%d"))
  )

  return(dataset)



}
