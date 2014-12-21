psychInfoWrangleR.f <- function(csv = FALSE, path){

#______________Install and Load Packages

    packages.f()

#______________Read EBSCO txt file _________________

    temp <- list.files(path, pattern = ".txt", full.names=TRUE)

    dat <- lapply(temp, readLines)

    attributes <- unlist(lapply(dat, function(x) stri_sub(x, 1,2)))

    # Add blank row to end of the file
    attributes[length(attributes)+1] <- ""

    # Set up indexing proceduring with a START and END
    #Blank line represents the end of the record
    attributes <- ifelse(attributes == "", "END", attributes)

    # Title represents start of the Index
    attributes <- ifelse(attributes == "TI", "START", attributes)
    attributes.df <- data.frame(attributes)

    record <- substring(unlist(dat), 5)
    record[length(record)+1] <- ""
    record.df <- data.frame(record)

    articleID <- rep(NA, length(attributes))
    START <- which(attributes== "START")
    END <- which(attributes == "END")
    DF <- cbind(attributes.df, articleID, record.df)

    for(i in 1:length(START)){DF$articleID[START[i]:END[i]] <- i}
    DF <- data.frame(lapply(DF, as.character), stringsAsFactors = FALSE)

    DF$attributes <- ifelse(DF$attributes == "START", "TI", DF$attributes)
    DF <- filter(DF, attributes != "END")

    # Extract tags of interest
    DF$record <- sub("^\\s+|\\s+$", "", DF$record)
    DF <- filter(DF,
                    attributes == "SO" |
                    attributes == "TI" |
                    attributes == "AU" |
                    attributes == "AF" |
                    attributes == "YR" |
                    attributes == "KP" |
                    attributes == "SU" |
                    attributes == "AB" |
                    attributes == "MJ" |
                    attributes == "CL" |
                    attributes == "PO" |
                    attributes == "AG" |
                    attributes == "TM" |
                    attributes == "MD" |
                    attributes == "LO" |
                    attributes == "DO")

    ebsco.titles <- filter(DF, attributes == "TI") %>%
        select(record) %>%
        mutate(record = tolower(record))

    ebsco.titles <- ebsco.titles[, 'record']
    ebsco.titles <- unlist(lapply(ebsco.titles, function(x) gsub(" ", "", x)))
    ebsco.titles <- unlist(lapply(ebsco.titles, function(x) gsub("[[:punct:]]", "", x)))

    ebsco.titles <- as.data.frame(ebsco.titles, stringsAsFactors = FALSE)

    ebsco.titles <- mutate(ebsco.titles, short.title = ebsco.titles) %>%
            select(-ebsco.titles) %>%
            mutate(articleID = c(1:nrow(ebsco.titles))) %>%
            select(articleID, short.title)

    ebsco.titles <<- ebsco.titles

    ebsco.df <<- DF
if(csv == TRUE){write.csv(ebsco.df, "ebsco.csv")}
cat("Wrangling is complete.")
if(csv == TRUE){cat("  The *.csv file can be found in your working directory.")}

}




