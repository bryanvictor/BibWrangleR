pmatch.f <- function(ebsco.titles, wos.titles){
    title.match <- pmatch(ebsco.titles, wos.titles)
    missing <- table(is.na(title.match))
    unique.matches <- title.match[!duplicated(title.match)]
    a.match <- list(title.match, missing, unique.matches)
    a.match
       }



