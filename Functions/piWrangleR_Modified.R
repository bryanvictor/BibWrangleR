piBWR.f <- function(csv = FALSE, path){

#______________Read EBSCO txt file _________________

    temp <- list.files(path, pattern = ".txt", full.names=TRUE)

    dat <- lapply(temp, readLines)

    attributes <- unlist(lapply(dat, function(x) stringi::stri_sub(x, 1,2)))

    attributes.df <- data.frame(attributes)

    #Take first five characters from each row
    record <- substring(unlist(dat), 5)

    record.df <- data.frame(record)
    DF <- cbind(attributes.df, record.df)
    DF <- data.frame(lapply(DF, as.character), stringsAsFactors = FALSE)


#_______________________________________________________________________________
#
#                       REMOVE DUPLICATE TI ENTRIES
#_______________________________________________________________________________

# Identify boundaries of each record -- starting with TI

DF$index <- 1:nrow(DF)
DF.temp <- filter(DF, attributes == "TI")





# Create another vector to hold values for identifying duplicates
DF.temp$duplicate <- rep(NA, length(DF.temp$index))

# Create a function to identify duplicates
n.records <- length(DF.temp$index)
i <- 2 #start with the second record

while(i < n.records)
    {
    DF.temp$duplicate[i] <- DF.temp$index[i] - DF.temp$index[i-1]
    i <- i + 1
    }

DF.temp.reduced <- filter(DF.temp, duplicate == 1)
duplicate.index <- as.character(DF.temp.reduced$index)
DF$index <- as.character(DF$index)

duplicate <- DF$index %in% duplicate.index
DF <- cbind(DF, duplicate)

DF <- filter(DF, duplicate == FALSE) %>%
        select(-index, -duplicate)



#Initialize an empty vector
DF$articleID <- cumsum(DF$attributes == "TI")

#_________________________________________________________________________
#
#       REMOVE DUPLICATE RECORDS
#_________________________________________________________________________

DF.temp <- filter(DF, attributes == "TI")
DF.temp <- arrange(DF.temp, record)
#DF.temp <- mutate(DF.temp, tolower(record))

unique.titles <- unique(DF.temp$record)

# Create another vector to hold values for identifying duplicates
DF.temp$duplicate <- rep(NA, length(DF.temp$articleID))

# Create a function to identify duplicates
n.records <- length(DF.temp$duplicate)
i <- 2 #start with the second record

while(i < n.records)
{
    DF.temp$duplicate[i] <- ifelse(DF.temp$record[i] == DF.temp$record[i-1], DF.temp$duplicate[i] <- TRUE, DF.temp$duplicate[i] <- FALSE)
    i <- i + 1
}

non.duplicate.ID <- filter(DF.temp, duplicate == FALSE) %>%
                    mutate(articleID = as.character(articleID))
non.duplicate.ID <- non.duplicate.ID$articleID

retain <- DF$articleID %in% non.duplicate.ID

DF <- DF[retain, ]


DF$record[DF$attributes == "SO"] <- gsub(" Special Issue", "", DF$record[DF$attributes == "SO"])
DF$record[DF$attributes == "SO"] <- gsub(":.*", "", DF$record[DF$attributes == "SO"])

#___________________________________________________________________________

pi.df <<- DF
if(csv == TRUE){write.csv(pi.df, "pi.csv")}
cat("Wrangling is complete.")
if(csv == TRUE){cat("  The *.csv file can be found in your working directory.")}

}




