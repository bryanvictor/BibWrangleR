BibWrangleR.f <- function(csv = FALSE){

#_________Install and Load Required Packages _____________
    pkgs <- c("stringi", "stringr", "dplyr", "gdata", "plyr")
    pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
    if (length(pkgs_miss) > 0) {
        install.packages(pkgs_miss)
    }

    if (length(pkgs_miss) == 0) {
        message("\n ...Packages were already installed!\n")
    }

    # install packages not already loaded:
    pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
    if (length(pkgs_miss) > 0) {
        install.packages(pkgs_miss)
    }

    # load packages not already loaded:
    attached <- search()
    attached_pkgs <- attached[grepl("package", attached)]
    need_to_attach <- pkgs[which(!pkgs %in% gsub("package:", "", attached_pkgs))]

    if (length(need_to_attach) > 0) {
        for (i in 1:length(need_to_attach)) require(need_to_attach[i], character.only = TRUE)
    }

    if (length(need_to_attach) == 0) {
        message("\n ...Packages were already loaded!\n")
    }

#______________Read EBSCO txt file _________________
            #my.path <- getwd()
            temp <- list.files(files.2.wrangle, pattern = ".txt")
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

#______________Read WOS files _________________
            my.path.wos <- getwd()
            temp <- list.files(my.path.wos, pattern = ".xls")
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


#__________________Match EBSCO file with WOS file_________________
            a.matching <- pmatch(ebsco.titles$short.title, wos.df$short.title)
            b.matching <- pmatch(wos.df$short.title, ebsco.titles$short.title)
            b.matching <- b.matching[!is.na(b.matching)]
            ebsco.match <- ebsco.titles[b.matching,]
            wos.match <- wos.df[a.matching,]

            ebsco.match <- ebsco.match[order(ebsco.match$short.title),]
            wos.match <- wos.match[order(wos.match$short.title),]
            wos.match <- wos.match[!is.na(wos.match$articleID),]

            ebsco.final.matched <<- ebsco.df[ebsco.df$articleID %in% ebsco.match$articleID, ]
            wos.final.matched <<- wos.df
            ebsco.original <<- ebsco.df
            rm(list= c("ebsco.titles"),envir=sys.frame(-1))

#__________________Create Output_____________________________

            if(csv == TRUE){write.csv(ebsco.df, "esbcoOriginal.csv")}
            if(csv == TRUE){write.csv(wos.df, "wosOriginal.csv")}
            if(csv == TRUE){write.csv(wos.match, "wosFinalMatched.csv")}
            if(csv == TRUE){write.csv(ebsco.final.matched, "ebscoFinalMatched.csv")}

            n.matched <- length(unique(ebsco.final.matched$articleID))
            prop.matched <- length(unique(ebsco.final.matched$articleID))/length(unique(ebsco.df$articleID))
            n.unmatched <- length(unique(ebsco.df$articleID))-length(unique(ebsco.final.matched$articleID))
            prop.unmatched <- n.unmatched/length(unique(ebsco.df$articleID))
            matching.summary <- list(n.original.records = length(unique(ebsco.df$articleID)),
                                     n.matched = n.matched,
                                     prop.match = prop.matched,
                                     n.unmatched = n.unmatched,
                                     prop.unmatched = prop.unmatched)
            cat("Parsing and matching is complete.  The objects for analysis are in the global environment.")
            if(csv == TRUE){cat("The csv files can be found in the same folder as the original data.")}
            matching.summary
    }

