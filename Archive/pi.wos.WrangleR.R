pi.wos.WrangleR.f <- function(csv=FALSE, path = NULL){

    a.matching <- pmatch(pi.titles$short.title, wos.df$short.title)
    b.matching <- pmatch(wos.df$short.title, pi.titles$short.title)
    b.matching <- b.matching[!is.na(b.matching)]
    ebsco.match <- pi.titles[b.matching,]
    wos.match <- wos.df[a.matching,]

    ebsco.match <- ebsco.match[order(ebsco.match$short.title),]
    wos.match <- wos.match[order(wos.match$short.title),]
    wos.match <- wos.match[!is.na(wos.match$articleID),]

    pi.match <<- pi.df[pi.df$articleID %in% ebsco.match$articleID, ]
    wos.match <<- wos.df
    #ebsco.original <<- pi.df
    #rm(list= c("ebsco.titles"),envir=sys.frame(-1))

    #__________________Create Output_____________________________

    #if(csv == TRUE){write.csv(ebsco.df, "esbcoOriginal.csv")}
    #if(csv == TRUE){write.csv(wos.df, "wosOriginal.csv")}
    if(csv == TRUE){write.csv(wos.match, "wosMatch.csv")}
    if(csv == TRUE){write.csv(pi.match, "piMatch.csv")}

    n.matched <- length(unique(pi.match$articleID))
    prop.matched <- length(unique(pi.match$articleID))/length(unique(pi.df$articleID))
    n.unmatched <- length(unique(pi.df$articleID))-length(unique(pi.match$articleID))
    prop.unmatched <- n.unmatched/length(unique(pi.df$articleID))
    matching.summary <- list(n.original.records = length(unique(pi.df$articleID)),
                             n.matched = n.matched,
                             prop.match = prop.matched,
                             n.unmatched = n.unmatched,
                             prop.unmatched = prop.unmatched)

    cat("Matching is complete and available as pi.match and wos.match in the global environment.")
    if(csv == TRUE){cat("\nThe csv files can be found in the same folder as the original data.\n")}
    matching.summary
}