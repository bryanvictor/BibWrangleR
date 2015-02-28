ebscoBWR.f <- function(csv = FALSE, path){

#_______________________________________________________________________________
#                           MAIN TO-DO LIST
#-------------------------------------------------------------------------------
#
#  1. Write code to ensure user has required packages dplyr, stringi, stringr
#     and there are no conflicts with the code
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
#                       0. Install Missing Packages
#-------------------------------------------------------------------------------
#
#All files to be wrangled should be saved in a single folder and have a *.txt
#extension.  The files must be processed from EbscoHost in the generic
#bibliographic format -- no other file structure will work.
#
#_______________________________________________________________________________


# leave this path for testing...
#path <- "/Users/beperron/Git/SocialWorkResearch/Data/ebscoFULL"

pkgs <- c("dplyr", "stringi", "stringr")
pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
if (length(pkgs_miss) > 0) {
    message("\n ...Installing missing packages!\n")
    install.packages(pkgs_miss)
}

if (length(pkgs_miss) == 0) {
    message("\n ...Packages were already installed!\n")
}


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

    rm(temp, dat, attributes, attributes.df, record, record.df)

# Create articleIDs
blank <- c("", "", "")
DF <- rbind(blank, DF)


variables.to.keep <- c("KW", "KP", "AD", "AF", "TI", "AU", "SO", "YR", "AB", "LO", "S2", "AF")

DF <- DF[DF$attributes %in% variables.to.keep, ]



#_______________________________________________________________________________
#                     2a. REMOVE MULTIPLE TI FIELDS
#-------------------------------------------------------------------------------
#
# Some records contain multiple TI fields when there is a translated title. To
# get an accurate count of the number of unique titles, the extra TI fields must
# be eliminated.  It is assumed that English titles are recorded first, and the
# second title is a foreing language.  The following code eliminates the foreign
# language.  This issue needs to be checked in occassions when searches are
# performed on the title itself.
#
#_______________________________________________________________________________
#Create an article identifier to group all records for a unique article.


x1 <- which(DF$attributes == "TI")
x2 <- x1+1
DF.x2 <- DF[x2, ]
duplicate <- which(DF.x2$attributes == "TI")
duplicate.ind <- as.numeric(row.names(DF.x2[duplicate, ]))

DF <- DF[-(duplicate.ind),]

#_______________________________________________________________________________
#                     2b. REMOVE MULTIPLE AB FIELDS
#-------------------------------------------------------------------------------
#
# SSA records contain two AB fields.  These AB records are always serially
# serially ordered, so the extraction method in 2a is reapplied here.
#_______________________________________________________________________________

x1 <- which(DF$attributes == "AB")
x2 <- x1+1
DF.x2 <- DF[x2, ]

table(DF.x2$attributes)
duplicate <- which(DF.x2$attributes == "AB")
duplicate.ind <- as.numeric(row.names(DF.x2[duplicate, ]))

DF <- DF[-(duplicate.ind),]


#_______________________________________________________________________________
#                    3.  REMOVE DUPLICATE RECORDS
#-------------------------------------------------------------------------------
# In the prior section, duplicate title (TI) fields were identified and excluded.
# These were non-matching titles because, for a given article, one title is in
# English and the other is in a foreing language.  In this section, the code is
# doing a global match for duplicate article records based on the title.
# Duplicates occur because multiple databases have overlapping indexing.
#_______________________________________________________________________________

#indx <- which(DF$attributes=="TI")



#What attributes precede TI (QUALITY CHECK)
#DF.temp <- DF[indx-1, ]
#table(DF.temp$attributes, useNA = "always")


#SU precedes TI without a blank space for a large number of records;
#Use following code to insert a blank row immediately preceding all TI records
#just to be safe. It creates additional article records that are blanks that
#can be easily removed

#newrow <- c("", "")
#insertRow <- function(DF, newrow, indx) {
#    DF[seq(indx-1,] <- [seq(indx,nrow(DF)),]
#    DF[indx,] <- newrow
#    DF
#}



#DF.temp.2 <- filter(DF.temp, attributes == "SU")

#DF$attributes[indx-1] <- ""
DF$articleID <- cumsum(DF$attributes == "TI")




#Select out all titles
DF.temp <- filter(DF, attributes == "TI")

    #Journal titles show discrepancies in capitalization rules.  Force all to
    #lower to address this problem.  Further testing should consider stripping
    #white space.
    DF.temp$record <- tolower(DF.temp$record)

    #Find duplicated records - duplicates are marked as true
    DF.temp <- DF.temp[duplicated(DF.temp$record), ]

    #Screen out duplicated records by articleID. The articleID must be used
    #because the duplicate title contains other article attributes
    DF.duplicated.ID <- DF.temp$articleID
    DF <- DF[!(DF$articleID %in% DF.duplicated.ID), ]

    rm(DF.temp, DF.duplicated.ID)


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

#_______________________________________________________________________________
#                        5. COMBINE YEAR FIELDS
#-------------------------------------------------------------------------------
#
# Year fields must be combined because each database uses a separate code.
# psychInfo uses the YR field; SSA, PD; and SWA, PD.  It is not possible to
# Simply rename PD to YR, because psycInfo also uses a PD field as another
# variable.  Thus, the PD values that are specific to psycInfo need to be
# eliminated before it can be replaced by the year (PD) field from SSA.
#_______________________________________________________________________________




    DF$attributes <- ifelse(DF$attributes == "PY", "YR", DF$attributes)

    DF.temp <- DF
    DF.temp <- filter(DF.temp, attributes == "PD")


    # APA appears to use a 6 to 8 digit identifier that needs to be excluded
    DF.temp$record<-sub("[0-9]{6,8}", "", DF.temp$record)

    #Eliminates "Bibiliography", "Graph" and "Table" from PD field
    DF.temp$record<-sub("[BGT]?[a-z]{4,11}", "", DF.temp$record)

    # Extract the first portion of the dates, up to the point with a 2 or 4
    # digit year value. This also captures some letters and characters.
    DF.temp$record <- stringr::str_extract(DF.temp$record,
                       "[$/A-Za-z0-9]+\\d{2,4}")

    #Exclude the characters
    DF.temp$record <- gsub("[/A-Za-z]", "", DF.temp$record)

    #Add 19 to all the records with just two digits
    DF.temp <- DF.temp[!is.na(DF.temp$record), ]
    DF.flag <- mutate(DF.temp,
           flag = ifelse(nchar(DF.temp$record) == 2, "1", "0" )) %>%
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
    }

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

#_______________________________________________________________________________
#            6b. AUTHOR FIELD FIX - AUTHORS IN SINGLE FIELD
#-------------------------------------------------------------------------------
#
# Social Work abstracts lists authors in a single cell, separated by a semi-
# colon, and then includes digits and email addresses in some occassions.
# The following text locates each author in the cell and places it into a new
# row to be consistent with PsychInfo and SSA.
#_______________________________________________________________________________


    #Create a new temporary data frame
    DF.temp <- filter(DF, attributes == "AU")

    #Identify records with semi-colons in author names
    semi.colons <- grepl("(;)", DF.temp$record)

    #Select out those records with semi-colons in author names from temporary
    #data frame
    DF.temp <- DF.temp[semi.colons, ]

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
    split.df$record <- ifelse(grepl("@", split.df$record) == TRUE, "",
                              split.df$record)
    split.df$record <- ifelse(nchar(split.df$record) <= 3, "",
                              split.df$record)
    split.df$record <- ifelse(grepl("\\.", split.df$record) == FALSE, "",
                              split.df$record)
    split.df$record <- ifelse(grepl("&", split.df$record) == TRUE, "",
                              split.df$record)
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
# After fixing the author fields in 6b, subsequent testing revealed a large
# number of email addresses that were still in the datafile and note excluded.
# This section is a patch for this issue.  This code should be re-written
# and integrated with the prior section.
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
#                       7. Minor Cleaning
#-------------------------------------------------------------------------------
#
# In this section, meaningful variable names are assigned to variables that have
# been cleaned and are appropriate for analysis.  All other variables are
# excluded to prevent inappropriate analyses.
#_______________________________________________________________________________

# Exclude UR record from the data file
DF$attributes <- ifelse(DF$attributes == "KW", "KP", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "AD", "AF", DF$attributes)

DF$attributes <- ifelse(DF$attributes == "TI", "article", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "AU", "author", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "SO", "journal", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "YR", "pubYear", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "AB", "abstract", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "KP", "keyWord", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "LO", "location", DF$attributes)
DF$attributes <- ifelse(DF$attributes == "S2", "journalSecondary",
                                                           DF$attributes)
DF$attributes <- ifelse(DF$attributes == "AF", "authorAff", DF$attributes)


variables.to.keep <- c("article", "author", "journal", "pubYear", "abstract",
                       "keyWord", "location", "journalSecondary", "authorAff")

DF <- DF[DF$attributes %in% variables.to.keep, ]

# Strip white-space
DF$record <- stringr::str_trim(DF$record, side="both")

DF$record <- ifelse(DF$attributes == "keyWord", tolower(DF$record), DF$record)


# Remove rownames
rownames(DF) <- NULL

# Reorder variables
DF <- select(DF, articleID, attributes, record)

rm(blank, path, sub.1, sub.2, sub.3, sub.4, sub.5, variables.to.keep)
#_______________________________________________________________________________
#                        8. OUTPUT
#-------------------------------------------------------------------------------
#
# This final section places a datafile in the global environment, which is
# called bwr.df.  If csv is specified as TRUE in the ebscoBWR function call,
# a csv file is written to the user's current working directory.  A few messages
# are written to the user's screen, providing a warning message and a few
# quality checks to ensure the number of articles matches the number of sources.
#_______________________________________________________________________________

    ebscoBWR.df <<- DF

rm(DF)

    if(csv == TRUE){write.csv(bwr.df, "ebscoBWR.csv")}

    cat(
"****************************************************
              Wrangling is complete
****************************************************")

    if(csv == TRUE){cat(
    "\nThe `ebscoBWR.csv` file can be found in your working directory.\n")}

}


