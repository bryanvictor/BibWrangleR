titleMatching.f <- function(x){
    titles <- filter(full.df, attributes == "article")
    titles$matching <- tolower(titles$record)

    #Eliminate `the` and `a` at the beginning of sentences and after colons
    titles$matching <- gsub("^the\\s", "", titles$matching)
    titles$matching <- gsub("^a\\s", "", titles$matching)
    titles$matching <- gsub("[[:punct:]]", "", titles$matching)
    titles$matching <- gsub("\\W", "", titles$matching)


    #Strips out white space and punctuation to ensure small differences in data
    #entry are detected during duplicate elimination
    titles$matching <- gsub(" ","", titles$matching)

    duplicated.titles <- duplicated(titles$matching)
    duplicated.ID <- titles$articleID[duplicated.titles]
    full.df <<- full.df[!(full.df$articleID %in% duplicated.ID), ]

}
