grepVar <- function(x, service, complete = FALSE){
    varsFile <- switch(service,
                   meteogalicia = 'varsMG',
                   gfs = 'varsGFS',
                   nam = 'varsNAM',
                   rap = 'varsRAP',
                       stop('Unknown service.'))
    ## Load the corresponding file
    data(list = varsFile)
    ## Read it
    vars <- eval(parse(text = varsFile))
    idx <- grep(x, vars$label, ignore.case=TRUE)
    if (isTRUE(complete)) vars[idx,]
    else as.character(vars$name[idx])
}
