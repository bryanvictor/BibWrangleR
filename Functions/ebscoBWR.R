ebscoBWR.f <- function(csv = FALSE, path){

#_______________________________________________________________________________
#                           MAIN TO-DO LIST
#-------------------------------------------------------------------------------
#
#  1. Write code to ensure user has required packages dplyr, stringi, stringr
#     and there are no conflicts with the code
#
#  2. Remove unnecessary objects at the end of each section.
#
#  3. Remove loop from section 3
#
#  4. Include note on importance of naming files to give priority
#
#  5. Integrate into Section 1 a function that checks each file for a blank line
#     at the end each text file.  Right now, a full carriage return must be
#     included, and no further quality checks are made.
#
#  6. Double check logic of section 4. Can we confirm that JN and SO are
#     problematic?
#
#  7. In Section 5, perform a test to ensure all APA codes are digits before
#     removing.
#
#  8.  Include a quality check at end of later sections to ensure TI and SO
#      match and are not reduced in subsequent parsing.
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

start.time <- Sys.time()

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

    rm(temp, dat, attributes, attributes.df, record, record.df)

end.time <- Sys.time()
section.1 <- end.time-start.time


#_______________________________________________________________________________
#                     2. REMOVE MULTIPLE TI FIELDS
#-------------------------------------------------------------------------------
#
#Some records contain multiple TI fields when there is a translated title. To
#get an accurate count of the number of unique titles, the extra TI fields must
#be eliminated.  It is assumed that English titles are recorded first, and the
#second title is a foreing language.  The following code eliminates the foreign
#language.  This issue needs to be checked in occassions when searches are
#performed on the title itself.
#
#_______________________________________________________________________________
start.time <- Sys.time()
    #Create and indexing variable to flag and remove items

    blank <- c("", "")
    DF <- rbind(blank, DF)

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

    rm(DF.temp, duplicate, DF.temp.duplicate, DF.temp.reduced, duplicate.index)

end.time <- Sys.time()
section.2 <- end.time-start.time
#_______________________________________________________________________________
#                    3.  REMOVE DUPLICATE RECORDS
#-------------------------------------------------------------------------------
# In the prior section, duplicate title (TI) fields were identified and excluded.
# These were non-matching titles because, for a given article, one title is in
# English and the other is in a foreing language.  In this section, the code is
# doing a global match for duplicate article records based on the title.
# Duplicates occur because multiple databases have overlapping indexing.
#_______________________________________________________________________________

start.time <- Sys.time()

    #Create an article identifier to group all records for a unique article.
    DF$articleID <- cumsum(DF$attributes == "")

    #Select out all titles
    DF.temp <- filter(DF, attributes == "TI")

    #Find duplicated records - duplicates are marked as true
    DF.temp <- DF.temp[duplicated(DF.temp$record), ]

    #Screen out duplicated records by articleID. The articleID must be used
    #because the duplicate title contains other article attributes
    DF.duplicated.ID <- DF.temp$articleID
    DF <- DF[!(DF$articleID %in% DF.duplicated.ID), ]

    rm(DF.temp, DF.duplicated.ID)

end.time <- Sys.time()
section.3 <- end.time-start.time

#_______________________________________________________________________________
#     4.  CLEAN JOURNAL NAMES AND MERGE JOURNAL NAME FIELDS (SO AND JN)
#-------------------------------------------------------------------------------
#
#Journals that have a Special Issue are not grouped together as the same
#title. These subtitles need to be removed.  Some articles have both the JN
#and SO code.  Thus, keeping both results in an excess count. A quality control
#check is to ensure the number of article titles is exactly equal to the
#unique number of journal title entries
#_______________________________________________________________________________

start.time <- Sys.time()

    DF$record[DF$attributes == "SO"] <- gsub(" Special Issue", "",
        DF$record[DF$attributes == "SO"])

    DF$record[DF$attributes == "SO"] <- gsub(":.*", "",
        DF$record[DF$attributes == "SO"])

    DF$record[DF$attributes == "JN"] <- gsub(" Special Issue", "",
        DF$record[DF$attributes == "JN"])

    DF$record[DF$attributes == "JN"] <- gsub(":.*", "",
        DF$record[DF$attributes == "JN"])

    #Create separate data files filtered by SO and JN, and a set of unique ID's
    journal.unique.SO <- filter(DF, attributes == "SO")
    journal.unique.JN <- filter(DF, attributes == "JN")
    articleID.unique <- unique(DF$articleID)

    #Which ID's overlap from JN to SO? This shows articles with both JN and SO
    #fields.
    JN.in.SO <- journal.unique.JN$articleID %in% journal.unique.SO$articleID

    #Filter out the ID from the JN that overlap with SO
    journal.unique.JN <- journal.unique.JN[!(JN.in.SO), ]
    journal.unique.JN <- mutate(journal.unique.JN, attributes = "SO")
    DF <- filter(DF, attributes != "JN")
    DF <- rbind(DF, journal.unique.JN)

    rm(journal.unique.SO, journal.unique.JN, articleID.unique, JN.in.SO)

end.time <- Sys.time()
section.4 <- end.time-start.time


#_______________________________________________________________________________
#                        5. COMBINE YEAR FIELDS
#-------------------------------------------------------------------------------
#
#
#_______________________________________________________________________________

start.time <- Sys.time()

    DF$attributes <- ifelse(DF$attributes == "PY", "YR", DF$attributes)

    DF.temp <- DF

    DF.temp <- filter(DF.temp, attributes == "PD")


    # APA appears to use a 6 to 8 digit identifier that needs to be excluded
    DF.temp$record <- ifelse(nchar(DF.temp$record) >= 6 &
                             DF.temp$attributes == "PD" &
                             nchar(DF.temp$record) <= 8 &
                             DF.temp$attributes == "PD",
                             "",
                             DF.temp$record)

    # Extract the first portion of the dates, up to the point with a 2 or 4
    # digit year value. This also captures some letters and characters.
    DF.temp$record <- stringr::str_extract(DF.temp$record,
                       "[$/A-Za-z0-9]+\\d{2,4}")

    #Exclude the characters
    DF.temp$record <- gsub("[/A-Za-z]", "", DF.temp$record)

    #Add 19 to all the records with just two digits
    DF.temp <- DF.temp[!is.na(DF.temp$record), ]
    DF.flag <- mutate(DF.temp, flag = ifelse(nchar(DF.temp$record) == 2, "1", "0" )) %>%
           filter(flag == "1") %>%
           group_by(record) %>%
           summarize(N = n())

    colnames(DF.flag)<-c("Year", "N")


    DF.temp$record <- ifelse(as.numeric(DF.temp$record) < 100,
                      paste("19", DF.temp$record, sep=""), DF.temp$record)
    DF.temp <- mutate(DF.temp, attributes = "YR")

    DF <- rbind(DF, DF.temp)
    DF <- arrange(DF, articleID)

    rm(DF.temp)

end.time <- Sys.time()
section.5 <- end.time-start.time

#_______________________________________________________________________________
#                            6a. AUTHOR FIELD FIX - DIGITS
#-------------------------------------------------------------------------------
#
# For articles pulled in from SSA, superscripts used to footnote affiliation get
# added to author's first name in the AU field
#_______________________________________________________________________________

DF.temp <- filter(DF, attributes == "AU")
DF.temp$record <- gsub("[[:digit:]]", "", DF.temp$record)
DF <- filter(DF, attributes != "AU")

DF <- rbind(DF, DF.temp)
DF <- arrange(DF, articleID)
rm(DF.temp)

#quality.check <- filter(DF, attributes == "TI"); dim(quality.check)
#dim(quality.check)

# quality.check <- filter(DF, attributes == "SO"); dim(quality.check)
# dim(quality.check)
#_______________________________________________________________________________
#            6b. AUTHOR FIELD FIX - AUTHORS IN SINGLE FIELD
#-------------------------------------------------------------------------------
#
#
#_______________________________________________________________________________



#Create a new temporary data frame
DF.temp <- filter(DF, attributes == "AU")

#Identify records with semi-colons in author names
semi.colons <- grepl("(;)", DF.temp$record)

#Select out those records with semi-colons in author names from temporary data
#frame
DF.temp <- DF.temp[semi.colons, ]


#Run split the strings and convert to long format

#Add a semi colon to the end of every string
DF.temp$record <- paste(DF.temp$record, ";", sep="")

semi.colon.split <- strsplit(DF.temp$record, ";")
split.df <- data.frame(
    attributes = rep(DF.temp$attributes, lapply(semi.colon.split, length)),
    record = unlist(semi.colon.split),
    articleID = rep(DF.temp$articleID, lapply(semi.colon.split, length)))



#Trim whitespace on both sides
split.df$record <- stringr::str_trim(split.df$record, side = "both")


#The author field is problematic because it contains some email address.
#Some fields have been improperly split because they were split on a semi-colon
#that was in the middle of the filed.

#Create a pattern that eliminates possible emails
split.df$record <- ifelse(grepl("@", split.df$record) == TRUE, "", split.df$record)
split.df$record <- ifelse(nchar(split.df$record) <= 3, "", split.df$record)
split.df$record <- ifelse(grepl("\\.", split.df$record) == FALSE, "", split.df$record)
split.df$record <- ifelse(grepl("&", split.df$record) == TRUE, "", split.df$record)
split.df <- filter(split.df, record != "")

# Create a vector of all articleID's that were fixed

fixed.ID <- unique(split.df$articleID)


#Filter out all processed records from the fixed list
DF.authors <- filter(DF, attributes == "AU")
DF.authors.good <- DF.authors[!(DF.authors$articleID %in% fixed.ID),]
DF.authors.fixed <- split.df
DF.no.authors <- filter(DF, attributes != "AU")

#Bind the reduced DF with the fixed df
DF <- rbind(DF.no.authors, DF.authors.good, DF.authors.fixed)
DF <- arrange(DF, articleID)

#_______________________________________________________________________________
#                       6c. E-mails
#-------------------------------------------------------------------------------
#
#
#_______________________________________________________________________________

DF.temp <- filter(DF, attributes == "AU")
sub.1 <- sub("^([^,]*,[^,]*),.*", "\\1", DF.temp$record)
sub.2 <- sub("[,\\.][a-zA-Z]{1,}@", "", sub.1)
sub.3 <- sub("@[a-zA-Z0-9.\\]{1,}", "", sub.2)
sub.4 <- sub("(\\s[a-z]{1,})$", "", sub.3)
sub.5 <- sub("(/&;#]+)", "", sub.4)
DF.temp$record <- sub.5
DF <- filter(DF, attributes != "AU")
DF <- rbind(DF, DF.temp)
DF <- arrange(DF, articleID)
rm(DF.temp)


#_______________________________________________________________________________
#                        8. OUTPUT
#-------------------------------------------------------------------------------
#
#
#_______________________________________________________________________________

bwr.df <<- DF
if(csv == TRUE){write.csv(pi.df, "pi.csv")}
cat("Wrangling is complete.\n")
if(csv == TRUE){cat("  The *.csv file can be found in your working directory.\n")}
cat("\nWarning: All years with two digits were prepended with 19 (century) automatically in the bwr function call. The function itself is not smart enough to determine if the values should be prepended with 20.  Be sure you check your data carefully.  And, make good choices.  \n\nThe following output shows the values of the years that were prepended and the respective number of data points.\n")
print(DF.flag)

print(section.1)
print(section.2)
print(section.3)
print(section.4)
print(section.5)
}

