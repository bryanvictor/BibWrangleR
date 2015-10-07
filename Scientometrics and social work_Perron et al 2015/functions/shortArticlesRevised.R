#Deletes article records associated with articles that are 3 pages or less
#(this can be adjusted below in this chunk)
shortArticles.f <- function(){

    pages.df<-filter(full.df, attributes=="pages")
    pages.df$record <- gsub("p", "", pages.df$record)
    pages.df$record <- gsub("ArtID:\\s", "", pages.df$record)
    pages.df$record<-gsub("S", "", pages.df$record)
    pages.df$record <- gsub(" ", "", pages.df$record)

    #Identify all records with dashes
    dashes.identifier<-filter(pages.df, grepl("-", record) )

    #Identify and remove all problematic records with dashes
    bad.pages <- grep("[^0-9]{1,}[-]|[-][^0-9]{1,}|^\\-|$\\-", dashes.identifier$record)
    dashes.df <- dashes.identifier[-bad.pages, ]

    #String split on dashes and then piece back together
    splitDash<-strsplit(dashes.df$record, "-")
    splitDash.df <- plyr::rbind.fill(lapply(splitDash, function(X) data.frame(t(X))))
    splitDash.df <- splitDash.df[,c(1,2)]
    colnames(splitDash.df) <- c("pageStart", "pageEnd")
    splitDash.df$pageStart<- as.numeric(as.character(splitDash.df$pageStart))
    splitDash.df$pageEnd<- as.numeric(as.character(splitDash.df$pageEnd))
    splitDash.df$record <- splitDash.df$pageEnd - splitDash.df$pageStart + 1
    splitDash.df <-select(splitDash.df, record)

    #Replace record column with new calculations
    dashesUpdated.df <- cbind(dashes.df, splitDash.df)
    dashesUpdated.df <- dashesUpdated.df[,c(1,2,4)]

#_________________________________________________________________

    noDashes.df <- pages.df[!pages.df$articleID %in% dashesUpdated.df$articleID, ]
    good.pages <- grepl("[0-9]+", noDashes.df$record)
    noDashes.df <- noDashes.df[good.pages, ]
    noDashes.df$record <- as.numeric(as.character(noDashes.df$record))


    pages.df<-rbind(dashesUpdated.df, noDashes.df)
    pages.df[is.na(pages.df)] <- 0


    pages.remove<-filter(pages.df, record < 3)    ## Set threshold for retaining articles by number of pages
    pages.remove.ID <- pages.remove$articleID

    full.df <- full.df[!full.df$articleID %in% pages.remove.ID, ]
    rownames(full.df) <- NULL

    pages.keep<-filter(pages.df, record>=3 & record <= 50)


    full.df<-filter(full.df, attributes!="pages")
    full.df<-rbind(full.df, pages.keep)
    full.df<<-full.df

}
