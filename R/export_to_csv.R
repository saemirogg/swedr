splitPath <- function(path){
  
  # Split path into directory and filename bits.    
  chunks <- unlist(strsplit(path, "/"))
  d <- paste(chunks[1:length(chunks)-1], collapse="/")
  f <- chunks[length(chunks)]
  result = c(dir=d, file=f)
  return(result)
  
}

convertToCSV <- function(path, overwrite=FALSE, max_rows=1024){
  # Loads all the object in RData file and converts to csv.
  # This may be convenient when using the data 
  # outside of R, like for example Python.
  #
  # Example usage:
  # path <- "/path/to/data/"
  # files <- list.files(path=path)
  # for (f in files) {
  #     if(grepl(".RData", f)) {
  #         convertToCSV(paste(path, f, sep=""), skip_if_exists=TRUE)
  #     }
  # }
  
  # First, create an environment to load the data into.
  e <- new.env(parent = emptyenv())
  
  # Load into environment
  message(paste("loading", f))
  load(path, envir=e)
  
  # Create an array of objects contained in RData file.
  objs <- ls(envir=e, all.names=TRUE)
  
  # Get the directory of current file
  d <- splitPath(path)["dir"]
  
  # Export each object in RData file and
  # write to csv file.
  for(obj in objs) {
    
    # Store object variable.
    .x <- get(obj, envir=e)
    
    # Create output path.
    new_file <- paste0(obj, '.csv')
    new_path <- file.path(d, new_file)
    
    # Check if the variable is a dataframe.
    if(is.data.frame(.x)){
      
      # Continue if file does not exist or should be overwritten
      if (!file.exists(new_path) | overwrite){                
        # Remove if exists
        if(file.exists(new_path)){file.remove(new_path)}
        
        nblocks <- nrow(.x) %/% max_rows + 1
        
        message(sprintf('Saving %s as %s', obj, new_path))                                                
        for(block in 1:nblocks){
          row_first <- (block-1) * max_rows + 1
          row_last <- (block) * max_rows
          if(row_last >= nrow(.x)){
            row_last <- nrow(.x)
          }
          
          select <- .x[row_first:row_last, colnames(.x)]
          message(
            sprintf(
              "block %d/%d: row %d-%d, with nrows: %d", 
              block, nblocks, row_first, row_last, nrow(select)
            )
          )                    
          
          write.table(select, new_path, 
                      append=file.exists(new_path), 
                      quote=TRUE, 
                      sep=",",
                      row.names=FALSE,
                      col.names=!file.exists(new_path))
        }
      }        
    }        
  }
}
