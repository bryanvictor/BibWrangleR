rm(list=ls())

#Load the user-defined functions
source("/Users/beperron/Git/BibWrangleR/functions/psychInfoWrangleR.R")
source("/Users/beperron/Git/BibWrangleR/functions/packages.R")
source("/Users/beperron/Git/BibWrangleR/functions/wosWrangleR.R")

my.path <- "/Users/beperron/Git/BibWrangleR/Files2Process"

#Parse the ebsco data
ebsco.data <- psychInfoBWR.f(csv=TRUE, path=my.path)

#Parse the wos data
wos.data <- wosBWR.f(csv=TRUE, path=my.path)




df <- ebsco.final.matched

# Number of authors per article
n.authors <- count(df[which(df$attributes == "AU"),],
      vars = c("articleID", "attributes"))

n.authors <- mutate(n.authors, articleID = as.numeric(articleID)) %>%
                arrange(articleID)

hist(n.authors$freq, xlim = c(1, 10))

df.years <- filter(df, attributes == "YR")

larger <- cbind(n.authors, df.years)


b1 <- summaryBy(freq ~ record, data = larger, FUN = function(x) {median(x)})

length(unique(df$articleID))



summaryBy(attributes ~ articleID, data = df[which(df$attribute %in% c("AU")),],
          FUN = list(length))

summaryBy(articleID ~ record, data=df[which(df$attribute == "YR"),],
          FUN = list(median))


df <- ebsco.final.matched

df.reduced <- df[which(df$attribute == "YR"),]







x.years <- filter(temp.test, attributes == "YR") %>%
    mutate(year = record) %>%
    select(year)

years <- unique(x.years)
years <- years[order(years),]




new.data <- ddply(temp.test, c("attribute", "record"), summarise,
                  N = length(record))




temp.test %>% group_by(articleID) %>%
    mutate(n.records = length(unique(articleID),
           n.authors = nrow(temp.test[temp.test$attribute == "AU"])))



                                                )

temp.new <- split(temp.au, temp.au$articleID)
author.count <- lapply(temp.new, nrow)

year.cnt <- filter(temp, attributes == "YR")
year.split <- split(year.cnt, year.cnt$record)
year.count <- lapply(year.split, nrow)

author.count
