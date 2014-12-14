
wosParser.f <- function(){

    library(plyr)
    my.path.wos <- getwd()
    temp <- list.files(my.path.wos, pattern = ".xls")
    dat <- lapply(temp, read.xls, stringsAsFactors=FALSE)
    WOSvariableNames <- dat[[1]][7,]
    colnames(WOSvariableNames) <- NULL

        cleaner.f <- function(x){
                colnames(x) <- NULL
                #x <- x[6:nrow(x), ]
                x <- x[8:nrow(x),]
                }

    wos <- lapply(dat, cleaner.f)
    wos <- ldply(wos, data.frame)
    colnames(wos) <- WOSvariableNames
    wos <- wos[,c(1:21, 112:137)]

    wos.titles <- select(wos, Title) %>%
    mutate(title = tolower(Title)) %>%
    select(-Title)
    wos.titles <- wos.titles[, 'title']
    wos.titles <- unlist(lapply(wos.titles, function(x) gsub(" ",  "", x)))
    wos.titles <- unlist(lapply(wos.titles, function(x) gsub("[[:punct:]]", "", x)))

    wos.titles <<- wos.titles
    wos.df <<- wos

}