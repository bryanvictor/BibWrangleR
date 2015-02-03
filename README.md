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

     (s)  Single for each recrod 
     (s+) One or more values for each record

`articleID` Unique identifier of each article.  (s)

`title`  Title of the article.  Based on the _TI_ fields from all three databases.  (s)

`author` Names of authors for each article.  Note that author names are in different formats due to formatting differences across database services.  Author names need further processing for subsequent analyses.  Unique author counts should not be conducted until formatting of names is standardized.  (s+)

`journal`  Title of journal. Every article has only one corresponding title.  Titles were derived from the _SO_ fields of _PI_, and `JN` from SSA and SWA.  (s)

`pubYear` Year of publication.  Publication year is derived from the _YR_ field of PI; _PD_ from SSA; and _PY_ from SWA. Years use standard 4-digit format (e.g., 2015).  (s)

`abstract` Abstract of corresponding journal article.  (s)

`keyWord` Author assigned keywords.  Keywords are derived from the _KP_ field from psycInfo and _KY_ field from SSA.  Social Work Abstracts does not provide keywords on export.  _KP_ field from psychInfo was originally a phrase and later changed to individual words.  Prior to 1995 (or approximately), psycInfo used key phrases instead of keywords. Analysis must consider this change in data type and adjust analyses accordingly.  (s+)

`location` **BRYAN description needed here**  [s]  

## Other known limitations
 

[1]: http://www.ebscohost.com/academic/psycinfo  "psycInfo"
[2]: http://www.ebscohost.com/academic/social-sciences-abstracts    "Social Science Abstracts"
[3]: http://www.ebscohost.com/academic/social-work-abstracts "Social Work Abstracts"