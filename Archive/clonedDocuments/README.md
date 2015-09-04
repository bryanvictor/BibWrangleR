BibWrangleR
===========

Brian E. Perron

Bryan G. Victor


BibWrangleR is a suite of functions that are designed to convert search results from major bibliographic indexing services into structured data files that can be easily analyzed.  This allows a wide range of analysis of scholarship within a particular field or topic area.  

Currently, BibWrangleR can create datafiles from psycInfo, Social Science Abstracts, and Social Work Abstracts administered by EbscoHost with the `ebscoBWR` function.  The `ebscoBWR` function may be useful for other databases hosted on the EbscoHost platform; however, to date, only these three database have been tested.  It is essential that including any other database beyond [psycInfo][1], [Social Science Abstracts][2], and [Social Work Abstracts][3] are thoroughly tested because of possible conflicts with variable names.  

This document provides an overview of the `ebscoBWR` function with respect to its usage and known limitations, as well as the variables available in the post-processed dataframe.    

## Usage

Provide description ... 

## Post-processed variables

This section provides an overview of the major variables that are contained in the post-processed data file.  For purposes of brevity, the following abbreviations are used:  psycInfo (PI), Social Science Abstracts (SSA), and Social Work Abstracts (SWA).  Every record (i.e., `article`) has the following variables.  All data are structured in a long format, and some records have multiple values for a single variable.  The following codes are used to indicate single and multiple variables:

     (s)  Single for each record 
     (s+) One or more values for each record

`articleID` Unique identifier of each article.  (s)

`article`  Title of the article.  Based on the _TI_ fields from all three databases.  (s)

`author` Names of authors for each article.  Note that author names are in different formats due to formatting differences across database services.  Author names need further processing for subsequent analyses.  Unique author counts should not be conducted until formatting of names is standardized.  (s+)

`journal`  Title of journal. Every article has only one corresponding title.  Titles were derived from the _SO_ fields of _PI_, and `JN` from SSA and SWA.  Some journals have a foreign language title and had a second field.  In the wrangling process, only the first title was retained.  The (s)

`journalSecondary` Secondary journal title.  Some journals operated under a different title, and these are included in this field.  These values are derived from the _S2_ field in PsychInfo.  The reliability of this information is not known.  (s+)

`pubYear` Year of publication.  Publication year is derived from the _YR_ field of PI; _PD_ from SSA; and _PY_ from SWA. Years use standard 4-digit format (e.g., 2015).  Some years were initially specified as having only two digits and the century was absent.  In preliminary testing, all these years were originally noted as 88 - 99.  These values were pre-pended with 19.  Future research should review the year variables before finalizing the process to ensure that they should not be prepended with 18 (historical articles) or 20 (current articles).  All years with two digits were prepended with 19 (century) automatically in the bwr function call. The function itself is not smart enough to determine if the values should be prepended with 20.  Be sure you check your data carefully. (s)

`abstract` Abstract of corresponding journal article.  Note that some articles may not have a corresponding abstract (s)

`keyWord` Author assigned keywords.  Keywords are derived from the _KP_ field from psycInfo and _KY_ field from SSA.  Social Work Abstracts does not provide keywords on export.  _KP_ field from psychInfo was originally a phrase and later changed to individual words.  Prior to 1995 (or approximately), psycInfo used key phrases instead of keywords. Analysis must consider this change in data type and adjust analyses accordingly.  (s+)

`location` Refers to where the research was conducted.  The location information is available only from psycInfo, so there will be many records without these values. [s]  

`authorAff` Author afilliations.  The values are derived from _AD_ fields in psycInfo and Social Science Abstracts, as well as the _AF_ fields from psycInfo  . Currently, these data are very messy -- the values from Social Work Abstracts are essentially just e-mail addresses or sometimes just the author's name.  Use of authorAff will require careful extraction of information through the use of regular expressions.  [s+]  


# Summary of Updates

February 3, 2015

+ added location to output
+ added author address to output
+ removed row names
+ re-ordered column names
+ removed duplicate Abstract entry from SSA
 
 

[1]: http://www.ebscohost.com/academic/psycinfo  "psycInfo"
[2]: http://www.ebscohost.com/academic/social-sciences-abstracts    "Social Science Abstracts"
[3]: http://www.ebscohost.com/academic/social-work-abstracts "Social Work Abstracts"
