pmatch.f <- function(){


    a.matching <- pmatch(ebsco.titles$short.title, wos.df$short.title)
    b.matching <- pmatch(wos.df$short.title, ebsco.titles$short.title)
    ebsco.match <- ebsco.titles[b.matching[3,]
    wos.match <- wos.df[a.matching[3,]

    ebsco.match <- ebsco.match[order(ebsco.match$short.title),]
    wos.match <- wos.match[order(wos.match$short.title),]
    wos.match <- wos.match[!is.na(wos.match$articleID),]

    ebsco.final.match <<- ebsco.df[ebsco.df$articleID %in% ebsco.match$articleID, ]
    #missing <- table(is.na(title.match))
    #unique.matches <- title.match[!duplicated(title.match)]
    #a.match <- list(title.match, missing, unique.matches)
    #rm(list = c("a.matching", "b.matching", "ebscoParser.f", "pmatch.f", "wosParser.f"))
    #a.match
       }








