grepVar <- function(x, service, complete = FALSE){
    varsFile <- switch(service,
                   meteogalicia = 'varsMG',
                   openmeteo = 'varsOM',
                   gfs = 'varsGFS',
                   nam = 'varsNAM',
                   rap = 'varsRAP')
    do.call(data, list(varsFile))
    vars <- eval(parse(text = varsFile))
    idx <- grep(x, vars$name, ignore.case=TRUE)
    if (isTRUE(complete)) vars[idx,]
    else vars$name[idx]
}
