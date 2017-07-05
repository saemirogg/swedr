# Takes in a Cox proportional hazards model and returns a table of the parameter estimates on a format
# specified by the user. The purpose of the function is to easily generate tables for research papers.
analysis_hazard_table <- function(fit,nr_digits=3,pval_type="stars",remove_adjustment=NULL,make_excel=T){
  require(xlsx)
  require(dplyr)
  require(xlsx)
  fix_decimal_places <- function(x,nr_digits){
    round(x*10^nr_digits)/10^nr_digits
  }
  summary_of_fit <- format(fix_decimal_places(summary(fit)$conf.int,nr_digits),
                    scientific=F)
  pvals <- summary(fit)$coefficients[,"Pr(>|z|)"]
  HR_conf_int <- paste(summary_of_fit[,"exp(coef)"],
                       " [",summary_of_fit[,"lower .95"],",",
                       summary_of_fit[,"upper .95"],"]",sep="")
  variable_names <- gsub("TRUE","",rownames(summary_of_fit))
  cox_table <- data.frame(col1=variable_names,col2=HR_conf_int)
  names(cox_table) <- c("Variable","HR [95%]")

  #Representation of p-values as specified by the user
  if(pval_type=="column"){
    #use cutoff deduced from nr_digits to represent pval in a seperate column
    cox_table$`p-value` <- ifelse(pvals<10^-nr_digits,paste0("<",10^-nr_digits),
                                  format(fix_decimal_places(pvals,nr_digits),
                                  scientific=F))
  }else if(pval_type=="stars"){
    #Level of significance labeled with different nr of stars
    stars <- cut(pvals,breaks=c(0,0.001,0.01,0.05,Inf),label=c("***","**","*",""),right=FALSE)
    cox_table$`HR [95%]` <- paste(cox_table$`HR [95%]`,stars,sep="")
  }else{
    stop("pval_type can only take the values 'column' or 'stars'. Type ?analysis_hazard_table for details")
  }

  #In some cases it is feasible to only show the non-adjusting variables
  cox_table %>% filter(!(Variable %in% remove_adjustment))
  if(make_excel){
    write.xlsx(cox_table,file = "cox_table.xlsx",row.names=F)
  }else{
    return(cox_table)
  }

}

