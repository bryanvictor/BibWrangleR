requireAuthorJournalTitleYear.f <- function(){

    titles <- filter(full.df, attributes == "article")
    journals <- filter(full.df, attributes == "journal")
    year <- filter(full.df, attributes == "pubYear")



    year.journal <- dplyr::intersect(year$articleID, journals$articleID)
    year.journal.titles <- dplyr::intersect(year.journal, titles$articleID)
    full.df <- full.df[full.df$articleID %in% year.journal.titles, ]

 
    author<-filter(full.df, attributes=="author")
    no.author<-filter(author, grepl("authorship|anonymous", record, ignore.case=TRUE))
    no.author.ID<-no.author$articleID
    full.df <<- full.df[!(full.df$articleID %in% no.author.ID),]

}
