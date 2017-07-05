# Function that appends two columns to part_data, the main cause of death (main_COD) and a full list of
# causes of death (COD).
add_COD <- function(part_data,wd=getwd()){
    require(dplyr)
    require(tidyr)
    setwd(wd)
    load("dors.Rdata")
    #extract columns names which have info on COD and combine the causes to one string to include all COD
    COD_names <- colnames(dors)[grepl("ORSAK",colnames(dors))]
    dors <- unite_(dors,"COD_full",COD_names,sep=" ") %>%
            mutate(COD_full=gsub("  .*","",COD_full))
    #append main COD, and full COD to input data
    part_data <- part_data %>% mutate(main_COD=dors$ULORSAK,COD=dors$COD_full,COD_ICD=dors$ICD)
    return(part_data)
}





