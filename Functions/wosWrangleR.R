wosWrangleR.f <- function(csv = FALSE, path){

    packages.f()

#______________Read WOS files _________________

temp <- list.files(path, pattern = ".xls", full.names=TRUE)
dat <- lapply(temp, read.xls, stringsAsFactors=FALSE)
WOSvariableNames <- dat[[1]][7,]
colnames(WOSvariableNames) <- NULL

cleaner.f <- function(x){
    colnames(x) <- NULL
    x <- x[8:nrow(x),]}

wos <- lapply(dat, cleaner.f)
wos <- ldply(wos, data.frame)
colnames(wos) <- WOSvariableNames
wos <- wos[,c(1:21, 112:137)]
wos$articleID <- c(1:nrow(wos))

wos   <- mutate(wos, short.title = tolower(Title)) %>%
    mutate(short.title = gsub(" ",  "", short.title)) %>%
    mutate(short.title = gsub("[[:punct:]]", "", short.title))

colnames(wos)[22:47] <- paste0("y", colnames(wos)[22:47])
wos.df <- select(wos, articleID, Title, short.title, Authors:y2015)
wos.df <<- wos.df

if(csv == TRUE){write.csv(wos.df, "wosOriginal.csv")}
cat("Wrangling is complete.")
if(csv == TRUE){cat("  The *.csv file can be found in your working directory.")}

}