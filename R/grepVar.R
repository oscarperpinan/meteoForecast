grepVar <- function(x, service, day = Sys.Date() - 1, complete = FALSE)
{
    timeFrame <- switch(service,
                        nam = 1,
                        rap = 1,
                        gfs = 0,
                        meteogalicia = 0)
    
    serviceURL <- composeURL(var = NULL, day = day, service = service, 
                             run = '00', spatial = NULL, timeFrame = timeFrame)

    serviceURL <- gsub('ncss', 'wcs', serviceURL)
    serviceURL <- gsub('/grid', '', serviceURL)
    wcsURL <- paste0(serviceURL,
                     '?service=WCS&version=1.0.0&request=GetCapabilities')
    xmlFile <- tempfile()
    download.file(wcsURL, xmlFile)
    wcs <- xmlParse(xmlFile)
    doc <- xmlRoot(wcs)
    content <- xmlChildren(doc)
    meta <- content[["ContentMetadata"]]

    vars <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

    idx <- grep(x, vars$label, ignore.case=TRUE)
    if (isTRUE(complete)) vars[idx,]
    else as.character(vars$name[idx])
}
