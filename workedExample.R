rm(list=ls())
library(stringi)
library(stringr)
library(dplyr)

#Load the function
source("/Users/beperron/Git/SWmeasures/EbscoParser.R")

#Read original data that is saved as *.txt file
record <- readLines("/Users/beperron/Desktop/records.txt")

#Parse the data
dat <- parser.f(record)
