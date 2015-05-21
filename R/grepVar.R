grepVar <- function(x, service, complete = FALSE){
    varsFile <- switch(service,
                       meteogalicia = 'varsMG',
                       openmeteo = 'varsOM',
                       gfs = 'varsGFS',
                       nam = 'varsNAM',
                       rap = 'varsRAP',
                       stop('Unknown service.'))
    vars <- eval(parse(text = varsFile))
    idx <- grep(x, vars$label, ignore.case=TRUE)
    if (isTRUE(complete)) vars[idx,]
    else as.character(vars$name[idx])
}
