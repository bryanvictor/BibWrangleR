ebscoBWR.f <- function(csv = FALSE, path){


#_______________________________________________________________________________
#                           MAIN TO-DO LIST
#-------------------------------------------------------------------------------
#
#  1. Write code to ensure user has required packages dplyr, stringi, stringr
#
#  2. Remove unnecessary objects at the end of each section.
#
#  3. Remove loop from section 3
#
#_______________________________________________________________________________


#_______________________________________________________________________________
#                           1. READ EBSCO txt files
#-------------------------------------------------------------------------------
#
#All files to be wrangled should be saved in a single folder and have a *.txt
#extension.  The files must be processed from EbscoHost in the generic
#bibliographic format -- no other file structure will work.
#
#_______________________________________________________________________________

    library(dplyr)
    temp <- list.files(path, pattern = ".txt", full.names=TRUE)

    dat <- lapply(temp, readLines)

    attributes <- unlist(lapply(dat, function(x) stringi::stri_sub(x, 1,2)))

    attributes.df <- data.frame(attributes)

    #Take first five characters from each row. These are the names of the record
    #values.
    record <- substring(unlist(dat), 5)

    record.df <- data.frame(record)

    DF <- cbind(attributes.df, record.df)

    DF <- data.frame(lapply(DF, as.character), stringsAsFactors = FALSE)

    # Clean up temporary objects
    rm(temp, attributes, record, attributes.df, record.df)

#_______________________________________________________________________________
#                     2. REMOVE MULTIPLE TI FIELDS
#-------------------------------------------------------------------------------
#Some records contain multiple TI fields when there is a translated title. To
#get an accurate count of the number of unique titles, the extra TI fields must
#be eliminated.  It is assumed that English titles are recorded first, and the
#second title is a foreing language.  The following code eliminates the foreign
#language.  This issue needs to be checked in occassions when searches are
#performed on the title itself.
#
#_______________________________________________________________________________

    #Create and indexing variable to flag and remove items
    DF$index <- 1:nrow(DF)

    #Filter out all rows with the TI (Title field)
    DF.temp <- filter(DF, attributes == "TI")

    #Identify duplicate entries by subtracting each sequential index value,
    #which is saved in as duplicate.
    duplicate <- diff(DF.temp$index)

    #The first entry does not have a value because it cannot be subtracted from
    #anything. The length of the duplicate variable is the length of the
    #index variable - 1.  Add a zero to the duplicate variable to make them the
    #same length.
    duplicate <- c(0, duplicate)

    #Set all duplicate records to 1, and all non-duplicates to 0.
    duplicate <- ifelse(duplicate == 1, 1, 0)

    #Bind the variable duplicate to the temporary file
    DF.temp.duplicate <- cbind(DF.temp, duplicate)

    #Filter out all the duplicate records
    DF.temp.reduced <- filter(DF.temp.duplicate, duplicate == 1)

    #Select out the index variable, which will be used to identify duplicate
    #records in the datafile being processed.
    duplicate.index <- DF.temp.reduced$index

    #Identify all duplicates in the main datafile (DF) by comparing the DF$index
    #values with those in the duplicate.index variable. This creates creates a
    #new variable (duplicate) with the values of TRUE (duplicate) and FALSE
    #(non-duplicate).
    duplicate <- DF$index %in% duplicate.index

    #Bind the new duplicate variable to the main datafile.
    DF <- cbind(DF, duplicate)

    #Filter out all the records that are non duplicates (FALSE)
    #Remove the temporary variables used to identify and remove duplicates.
    DF <- filter(DF, duplicate == FALSE) %>% select(-index, -duplicate)



#_______________________________________________________________________________
#                    3.  REMOVE DUPLICATE RECORDS
#-------------------------------------------------------------------------------
#_______________________________________________________________________________

#Initialize an empty vector
DF$articleID <- cumsum(DF$attributes == "TI")

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


#____________________Fix Journal Titles________________________________________________________
#Identify which journals have the JN code but not the SO code.
DF$record[DF$attributes == "SO"] <- gsub(" Special Issue", "", DF$record[DF$attributes == "SO"])
DF$record[DF$attributes == "SO"] <- gsub(":.*", "", DF$record[DF$attributes == "SO"])

DF$record[DF$attributes == "JN"] <- gsub(" Special Issue", "", DF$record[DF$attributes == "JN"])
DF$record[DF$attributes == "JN"] <- gsub(":.*", "", DF$record[DF$attributes == "JN"])


articleID.unique <- unique(DF$articleID)
journal.unique.SO <- filter(DF, attributes == "SO")
journal.unique.JN <- filter(DF, attributes == "JN")

#Which ID's overlap from JN to SO?
JN.in.SO <- journal.unique.JN$articleID %in% journal.unique.SO$articleID

#Filter out the ID from the JN that overlap with SO
journal.unique.JN <- journal.unique.JN[!(JN.in.SO), ]
journal.unique.JN <- mutate(journal.unique.JN, attributes = "SO")

DF <- filter(DF, attributes != "JN")

DF <- rbind(DF, journal.unique.JN)


#____________________________COMBINE Year FIELDS________________________________

DF$attributes <- ifelse(DF$attributes == "PY", "YR", DF$attributes)

DF.temp <- DF

DF.temp <- filter(DF.temp, attributes == "PD")


# APA appears to use a 6 to 8 digit identifier that needs to be excluded
DF.temp$record <- ifelse(nchar(DF.temp$record) >= 6 & DF.temp$attributes == "PD" &
                         nchar(DF.temp$record) <= 8 & DF.temp$attributes == "PD",
                         "", DF.temp$record)

# Extract the first portion of the dates, up to the point with a 2 or 4 digit
# year value. This also captures some letters and characters.
DF.temp$record <- stringr::str_extract(DF.temp$record, "[$/A-Za-z0-9]+\\d{2,4}")

#Exclude the characters
DF.temp$record <- gsub("[/A-Za-z]", "", DF.temp$record)

#Add 19 to all the records with just two digits

DF.temp <- DF.temp[!is.na(DF.temp$record), ]
DF.flag <- mutate(DF.temp, flag = ifelse(nchar(DF.temp$record) == 2, "1", "0" )) %>%
           filter(flag == "1") %>%
           group_by(record) %>%
           summarize(N = n())

colnames(DF.flag)<-c("Year", "N")


DF.temp$record <- ifelse(as.numeric(DF.temp$record) < 100, paste("19", DF.temp$record, sep=""), DF.temp$record)
DF.temp <- mutate(DF.temp, attributes = "YR")

DF <- rbind(DF, DF.temp)
DF <- arrange(DF, articleID)

#____________________________________________________________________________________________


bwr.df <<- DF
if(csv == TRUE){write.csv(pi.df, "pi.csv")}
cat("Wrangling is complete.\n")
if(csv == TRUE){cat("  The *.csv file can be found in your working directory.\n")}
cat("\nWarning: All years with two digits were prepended with 19 (century) automatically in the bwr function call. The function itself is not smart enough to determine if the values should be prepended with 20.  Be sure you check your data carefully.  And, make good choices.  \n\nThe following output shows the values of the years that were prepended and the respective number of data points.\n")
print(DF.flag)
}

