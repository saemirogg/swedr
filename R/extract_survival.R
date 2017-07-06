#'
#'
#'
#'
#'
#'
#'


extract_survival <- function(dataset,events,censoring=c(),first_event="incl_date"){

  #If any events are also being censored the function is stopped
  if(any(events %in% censoring))
    stop("Some events are also being censored")

  #Getting the column numbers of events and censored events
  events_col <- which(names(dataset) %in% events)
  censoring_col <- which(names(dataset) %in% censoring)

  #Getting the columns of data requested along with death and FU
  dates_data <- data.frame(dataset$death_date,dataset$FU,dataset[,c(events_col,censoring_col)])

  #Pulling out first date
  day_first <- unlist(dataset[which(names(dataset) == first_event)])

  #if there are any NAs after that there will be an error
  if(sum(is.na(day_first)) != 0)
     stop("There are participants with an unknown date (NA) of inclusion")

  #Pulling out the last date
  day_last <- apply(dates_data,1,min,na.rm=T)

  #Is there an event or not on the last day in the study. If so that participant is considered having an event.
  #min throws an error if you hand it a vector of only NAs therefore we create this custom function giving those vectors that has only NAs
  event_yn <- apply(select(dataset,events_col),1,FUN=function(x){
    if(sum(!is.na(x) > 0))
       y <- min(x,na.rm=T)
    else{
      y <- Inf
      }
    return(y)
    }  ) == day_last
  #for those that never have any event we need to change NA of event_yn to FALSE
  event_yn <- ifelse(is.na(event_yn),FALSE,event_yn)

  time_in_study <- days_diff(day_first,day_last)

  return(cbind(dataset,day_last,event_yn,time_in_study))
}
