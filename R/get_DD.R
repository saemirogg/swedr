get_DD <- function(part_data,year1=0,year2=20140101,wd=getwd(),outp=T,inp=T){
  #getting wd
  or_wd <- getwd()
  setwd(wd)

  if(outp==T){
    load("clean_ov.RData")

    dia_data <- filter(clean_ov,
                       LopNr %in% part_data$lop_nr,
                       INDATUMA > year1,
                       INDATUMA < year2
    ) %>%
      mutate(setting="outp") %>%
      select(lop_nr=LopNr,DIAGNOS,INDATUMA,setting)
    rm(clean_ov)
  }

  if(inp==T){

    load("clean_sv.RData")
    if(outp==T)
      dia_data <- rbind(dia_data,
                        filter(clean_sv,
                             LopNr %in% part_data$lop_nr,
                               INDATUMA > year1,
                               INDATUMA < year2) %>%
                          mutate(setting="inp") %>%
                          select(lop_nr=LopNr,DIAGNOS,INDATUMA,setting)

      )
    if(outp==F)
      dia_data <- filter(clean_sv,
                         LopNr %in% part_data$lop_nr,
                         INDATUMA > year1,
                         INDATUMA < year2
      ) %>%
        mutate(setting="inp") %>%
        select(lop_nr=LopNr,DIAGNOS,INDATUMA,setting)


    rm(clean_sv)
  }

  setwd(or_wd)

  #lop_nr should be a numeric
  dia_data$lop_nr <- as.numeric(dia_data$lop_nr)


  return(dia_data)

}
