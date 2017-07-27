#' Transforms selected columns from the format provided by add_diagnoses
#' to a binary representation, useful to do Cox regression
extract_binary <-function(part_data,vars){
  require(dplyr)
  require(magrittr)
  binary_data <- part_data %>% mutate_at(.funs=funs(is.na),.vars=vars) %>%
    mutate_at(.funs=funs(not),.vars=vars)
  return(binary_data)
}
