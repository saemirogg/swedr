#'
#'
#'
#'
#'
#'
#'

verify_cancer <- function(partdata,
                          dx,wd=getwd(),remove=T){
  #load the cancer registry
  setwd(wd)
  load("can.RData")

  dx <- paste(dx,collapse="|")

  ##Subsetting the data to only cancer diagnoses of interest
  can <- filter(can,
                grepl(dx,ICD7) | grepl(dx,ICD9) | grepl(dx,ICDO10))
  #Adding verified column to data
  #A person is verified if its cancer diagnosis is recorded in the cancer registry or if its corresponding case
  #is recorded in the cancer registry.
  partdata <- partdata %>% mutate(verified =
                          (partdata$lop_nr %in% can$LopNr & partdata$case) |
                          partdata$lop_nr_case %in% can$LopNr)

  #Giving data on the verification process
  warning(with(partdata,sum(case & !verified))," (",round(with(partdata,sum(case & !verified)/sum(partdata$case)),digits = 2)*100,
          "%) cases are not in the cancer registry. There are ",sum(!partdata$case & partdata$lop_nr %in% can$LopNr),
          " controls that have a diagnosis of the given cancer.")
  if(remove){
    warning("These ",with(partdata,sum(case & !verified))," cases and their corresponding ",
            with(partdata,sum(case & !verified))," controls have been removed.")
    partdata <- partdata %>% filter(verified) %>% select(-verified)
  }
  return(partdata)
}
