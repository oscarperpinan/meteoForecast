
grepVar <- function(x, service, day = Sys.Date() - 15, complete = FALSE)
{
    serviceURL <- composeURL(var = NULL, day = day, service = service, 
                             run = '00', spatial = NULL, timeFrame = 0)
    
    wcsURL <- paste0(gsub('ncss/grid', 'wcs', serviceURL),
                     '?service=WCS&version=1.0.0&request=GetCapabilities')

    wcs <- xmlParse(wcsURL)
    doc <- xmlRoot(wcs)
    content <- xmlChildren(doc)
    meta <- content[["ContentMetadata"]]

    vars <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

    idx <- grep(x, vars$label, ignore.case=TRUE)
    if (isTRUE(complete)) vars[idx,]
    else as.character(vars$name[idx])
}
