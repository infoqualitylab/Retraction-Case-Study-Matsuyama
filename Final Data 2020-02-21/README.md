# Files in the folder:
* nodes.csv
* nodes.xlsx
* edges.csv

**Date Updated: 2020-02-21**

## Relationship between files:
* nodes.csv - List of nodes (ID, author, title, year). Each node represents a paper.
* nodes.xlsx - Same as nodes.csv but uses full non-escaped Unicode in author and title fields
* edges.csv - List of edges. Each edge represents a citation between two papers.
  
### 1) nodes.csv 

Variable list, defining any abbreviations, units of measure, codes or symbols used:

* ID - ID for the paper/node. IDs follow the following conventions:

A000 represents the retracted Matsuyama paper.

F### represents a first-generation citation that directly cites the retracted Matsuyama paper.

F###S### represents a second-generation citation that does not cite the retracted Matsuyama paper but that cites some first-generation citation (where F### is one of the first-generation articles it cites).

* Author - Author list for the paper/node from Google Scholar or Web of Science. (Escaped Unicode.)
* Title - Title for the paper/node from Google Scholar or Web of Science. (Escaped Unicode.)
* Year - Year for the paper/node from Google Scholar or Web of Science and/or our determination. Some year data was updated when errors were found or when year was missing from Google Scholar data. Note: NA when no year is available.

Missing data codes: NA

### 2) nodes.xlsx

Same as nodes.csv except for formatting. Includes non-Latin characters in Author and Title.

### 3) edges.csv

Variable list, defining any abbreviations, units of measure, codes or symbols used:

* from - ID for the cited paper. This is what the citation goes FROM. All IDs are from deduplicated nodes.csv and follow the conventions above.
* to - ID for the citing paper. This is what the citation goes TO. All IDs are from deduplicated nodes.csv and follow the conventions above.

