rm(list=ls())
library(stringi)
library(stringr)
library(dplyr)
library(gdata)

#Load the function
source("/Users/beperron/Git/DataWranglers/ebscoParser.R")

#Read original data that is saved as *.txt file
ebsco.file <- readLines("/Users/beperron/Git/DataWranglers/RSWP-ebsco/ebsco.txt")

#Parse the ebsco data
ebscoParser.f(ebsco.file)

#Parse the wos data
source("/Users/beperron/Git/DataWranglers/wosParser.R")
wosParser.f()

#Find matches using partial matching function
source("/Users/beperron/Git/DataWranglers/pmatch.R")

#Create a matched and merged data file
a.matching <- pmatch.f(ebsco.titles$short.title, wos.df$short.title)
b.matching <- pmatch.f(wos.df$short.title, ebsco.titles$short.title)


ebsco.match <- ebsco.titles[b.matching[[3]],]
wos.match <- wos.df[a.matching[[3]],]

ebsco.match <- ebsco.match[order(ebsco.match$titles),]
wos.match <- wos.match[order(wos.match$titles),]
wos.match <- wos.match[!is.na(wos.match$articleID),]

ebsc.final.match <- ebsco.df[ebsco.df$articleID %in% ebsco.match$articleID, ]

#General cleanup
rm(list = c("a.matching", "b.matching", "ebsco.file",
          "ebscoParser.f", "pmatch.f", "wosParser.f"))




