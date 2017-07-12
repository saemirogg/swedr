#'
#'
#'
#'
#'
#'


add_cancer <- function(part_data,dx_path,wd=getwd(),ignore=NULL){

  #set original wd and set up new wd
  or_wd <- getwd()
  setwd(wd)

  #retrieving the cancer registry
  load("can.RData")
  dia_data=can

  #Reading excel data and converting into table with variable names and the corresponding codes in one character
  #the codes are on a " X| Y| B| C" format to look for a space and the code so as to protect agains mismatches between different codes
  #e.g. "56|89" would pick upp the codes C56,J56 etc. The space eliminates this problem.
  dx_codes <- read_excel(path=dx_path) %>%
    group_by(variable_name) %>%
    summarise(dia_codes=paste(" ",paste(dia_codes,collapse="| "),sep=""))

  #Adding data for the interpretation of each value (time, relationship etc.)
  dx <- read_excel(path=dx_path,sheet=2) %>%
    slice(match(dx_codes$variable_name,.$variable_name)) %>%
    select(2:ncol(.)) %>%
    bind_cols(dx_codes,.)

  new_data <- plyr::daply(.data = dx,
                          .variables = "variable_name",
                          .drop_o=FALSE,
                          .fun = function(x) {add_event(
                            part_data=part_data,
                            dia_data=dia_data,
                            dx=x[["dia_codes"]],
                            relationship=x[["relationship"]],
                            before_time=c(x[["before_time1"]],x[["before_time2"]]),
                            after_time=c(x[["after_time1"]],x[["after_time2"]]),
                            cancer=T,
                            exclude_outside=x[["exclude_outside"]],
                            ignore= x[["variable_name"]] %in% ignore)
                          }
  )

  #The result is variable_name x dates matrix and needs to be transposed and turned into a data frame and combined with the original part data
  output_data <- bind_cols(part_data,as.data.frame(t(new_data)))

  #Finding those that are included, i.e. have not been excluded in the add_event function
  #There they have been marked as a 0 so if there is a zero in the line the participant is excluded
  included <- !(apply(t(new_data),1,FUN=function(x){any(x==0,na.rm = T)}))


  #Removing participants marked for exclusion
  output_data <- filter(output_data, included)

  if(any(!included)){
    warning(sum(!(included))," participants met the exclusion criteria and were excluded")
  }

  #Setting back to original wd
  setwd(or_wd)

  return(output_data)

}
