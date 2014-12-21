ebsco.wos.WrangleR.f <- function(csv=FALSE){

    a.matching <- pmatch(ebsco.titles$short.title, wos.df$short.title)
    b.matching <- pmatch(wos.df$short.title, ebsco.titles$short.title)
    b.matching <- b.matching[!is.na(b.matching)]
    ebsco.match <- ebsco.titles[b.matching,]
    wos.match <- wos.df[a.matching,]

    ebsco.match <- ebsco.match[order(ebsco.match$short.title),]
    wos.match <- wos.match[order(wos.match$short.title),]
    wos.match <- wos.match[!is.na(wos.match$articleID),]

    ebsco.final.matched <<- ebsco.df[ebsco.df$articleID %in% ebsco.match$articleID, ]
    wos.final.matched <<- wos.df
    ebsco.original <<- ebsco.df
    #rm(list= c("ebsco.titles"),envir=sys.frame(-1))

    #__________________Create Output_____________________________

    if(csv == TRUE){write.csv(ebsco.df, "esbcoOriginal.csv")}
    if(csv == TRUE){write.csv(wos.df, "wosOriginal.csv")}
    if(csv == TRUE){write.csv(wos.match, "wosFinalMatched.csv")}
    if(csv == TRUE){write.csv(ebsco.final.matched, "ebscoFinalMatched.csv")}

    n.matched <- length(unique(ebsco.final.matched$articleID))
    prop.matched <- length(unique(ebsco.final.matched$articleID))/length(unique(ebsco.df$articleID))
    n.unmatched <- length(unique(ebsco.df$articleID))-length(unique(ebsco.final.matched$articleID))
    prop.unmatched <- n.unmatched/length(unique(ebsco.df$articleID))
    matching.summary <- list(n.original.records = length(unique(ebsco.df$articleID)),
                             n.matched = n.matched,
                             prop.match = prop.matched,
                             n.unmatched = n.unmatched,
                             prop.unmatched = prop.unmatched)

    cat("Parsing and matching is complete.  The objects for analysis are in the global environment.")
    if(csv == TRUE){cat("The csv files can be found in the same folder as the original data.")}
    matching.summary
}