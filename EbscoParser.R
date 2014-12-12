parser.f <- function(dat){
            attributes <- unlist(lapply(dat, function(x) stri_sub(x, 1,2)))
            attributes[length(attributes)+1] <- "" #add blank row
            attributes <- ifelse(attributes == "", "END", attributes)
            attributes <- ifelse(attributes == "TI", "START", attributes)
            attributes.df <- data.frame(attributes) #Save as a data frame

            record <- substring(dat, 5)
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

            DF$record <- sub("^\\s+|\\s+$", "", DF$record)
            DF
    }


