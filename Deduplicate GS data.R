## load packages
library(tidyverse)
library(sets)

## import datasets
nodes = read.csv("GSdata/GS nodes.csv", encoding = "UTF-8")
edges = read.csv("GSdata/GS edges.csv", encoding = "UTF-8")

## deduplicate GS nodes
nodes = as_tibble(nodes)
nodes
dupli = which(duplicated(nodes$Title))

## find dudplicated nodes
distinctnodes = nodes[!duplicated(nodes$Title),]
idseta = as.set(nodes$X.U.FEFF.ID)
idsetb = as.set(distinctnodes$X.U.FEFF.ID)
diff = idseta - idsetb
diff = as.character(diff)

## find dudplicated titles and ids
titles = nodes$Title[nodes$X.U.FEFF.ID %in% diff]
ids = nodes$X.U.FEFF.ID[nodes$X.U.FEFF.ID %in% diff]
deleteddf = data.frame(ids, titles)
nrow(deleteddf)

## final titles and ids to be kept
disids = distinctnodes$X.U.FEFF.ID[distinctnodes$Title %in% uniquetitles]
distitles = distinctnodes$Title[distinctnodes$Title %in% uniquetitles]
disdf = data.frame(disids, distitles) ## final IDs
nrow(disdf)

for (i in 1:nrow(deleteddf)) {
  deleteddf$realids[i] = as.character(disdf$disids[which(disdf$distitles == deleteddf$titles[i])])
}

## clean up edges
for (i in 1:nrow(deleteddf)) {
  edges$to[which(edges$to == as.character(deleteddf$ids[i]))] = deleteddf$realids[i]
}
edges = distinct(edges)
write.csv(distinctnodes, "deduplicated nodes.csv", fileEncoding = "UTF-8", row.names = FALSE)
# write.csv(edges, "deduplicated edges.csv", fileEncoding = "UTF-8", row.names = FALSE)

