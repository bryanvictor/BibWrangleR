combineData.f <- function(){
    # Combines EbscoHost and ProQUest

    #Creates variable with highest article ID from ebscohost database
    ebscoIDmax<-max(ebscoBWR.df$articleID)

    #Recodes article ID in ProQuest database in advance of merger with ebscohost
    proQuestBWR.df<-mutate(proQuestBWR.df, articleID=articleID+ebscoIDmax)

    full.df <- rbind(ebscoBWR.df, proQuestBWR.df)


    year.25 <- as.character(c(1910:1988, 2014, 2015))

    temp.df <- filter(full.df, attributes == "pubYear")

    year.remove <- temp.df[temp.df$record %in% year.25, ]
    year.removeID <- year.remove$articleID

    full.df <- full.df[!(full.df$articleID %in% year.removeID), ]
    full.df <<- full.df
    #article.count.initial <<- filter(full.df, attributes == "article") 
    journal.count <- filter(full.df, attributes == "journal")
    #journal.count.initial <<- length(unique(journal.count$record))
}
    
    
    
