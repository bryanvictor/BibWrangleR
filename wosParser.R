wosParser.f <- function(){

    library(plyr)
    library(gdata)
    my.path.wos <- getwd()
    temp <- list.files(my.path.wos, pattern = ".xls")
    dat <- lapply(temp, read.xls, stringsAsFactors=FALSE)
    WOSvariableNames <- dat[[1]][7,]
    colnames(WOSvariableNames) <- NULL

        cleaner.f <- function(x){
                colnames(x) <- NULL
                x <- x[8:nrow(x),]
                }

    wos <- lapply(dat, cleaner.f)
    wos <- ldply(wos, data.frame)
    colnames(wos) <- WOSvariableNames
    wos <- wos[,c(1:21, 112:137)]
    wos$articleID <- c(1:nrow(wos))

    wos   <- mutate(wos, short.title = tolower(Title)) %>%
             mutate(short.title = gsub(" ",  "", short.title)) %>%
             mutate(short.title = gsub("[[:punct:]]", "", short.title))

    colnames(wos)[22:47] <- paste0("y", colnames(wos)[22:47])
    wos <- select(wos, articleID, Title, short.title, Authors:y2015)

    wos.df <<- wos
}