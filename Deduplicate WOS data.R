## load packages
library(tidyverse)
library(dplyr)
library(gdata) # drop.levels

## import datasets
path = "WOS cleaned/"
nodes = read.csv("WOS FG ids.csv", encoding = "UTF-8")
temp = list.files(path = "WOS cleaned", pattern="*.csv")
myfiles = lapply(paste0(path, as.character(temp), seq = ""), read.csv)
temp.nodes = nodes[order(nodes$Title),]
temp.nodes$X.U.FEFF.ID = as.character(temp.nodes$X.U.FEFF.ID)
temp.nodes = temp.nodes[temp.nodes$X.U.FEFF.ID <= "F073",]
df = data.frame(csv = temp, title = c(as.character(temp.nodes$Title), rep(NA, 3)), id = c(temp.nodes$X.U.FEFF.ID, rep(NA, 3)))

## Hard code IDs to match up with GS nodes' IDs
for (i in 1:3) {
  myfiles[[i]]$fg = df$id[i]
}

for (i in 4:20) {
  myfiles[[i]]$fg = df$id[i+1]
}
for (i in 22:26) {
  myfiles[[i]]$fg = df$id[i]
}
for (i in 33:38) {
  myfiles[[i]]$fg = df$id[i-4]
}
for (i in 40:42) {
  myfiles[[i]]$fg = df$id[i-2]
}
myfiles[[39]]$fg = df$id[36]
myfiles[[43]]$fg = df$id[35]
myfiles[[28]]$fg = df$id[28]

myfiles[[21]]$fg = "F115"
myfiles[[27]]$fg = "F137"
myfiles[[29]]$fg = "F135"
myfiles[[30]]$fg = "F135"
myfiles[[31]]$fg = "F006"
myfiles[[32]]$fg = "F138"

names(myfiles[[30]]) <- names(myfiles[[1]]) 
names(myfiles[[29]]) <- names(myfiles[[1]]) 
alldf = do.call("rbind", myfiles)
distinctnodes = alldf[!duplicated(alldf$Title),]
distinctnodes = distinctnodes[,c(ncol(distinctnodes), 1:(ncol(distinctnodes)-1))]

# write.csv(distinctnodes, "deduplicated WOS nodes.csv", fileEncoding = "UTF-8", row.names = FALSE)


## combine GS and WOS
gsnodes = read.csv("deduplicated GS nodes.csv", encoding = "UTF-8")
gsnodes = gsnodes[, c(1, 3:5)]
wosnodes = nodes[order(nodes$X.U.FEFF.ID), c(1:3, 9)]
wosnodes = wosnodes[c(48:54),] ## keep only the unique nodes in wos
wosnodes = wosnodes[!duplicated(wosnodes$Title),]
names(wosnodes)[4] = "Year"
wosnodes = wosnodes[,c(1,3,2,4)]
nodes = rbind(gsnodes, wosnodes)

## clean up unique nodes' second-generation articles
sg = distinctnodes[as.character(distinctnodes$fg) >= "F135",]
# hardcode sg ids and edges
edges = read.csv("deduplicated GS edges.csv", encoding = "UTF-8")
levels(sg$fg) = c(levels(sg$fg), "F137S000", "F033S001", "F135S000", "F135S001", "F138S000")
sg$fg = c("F033S001", "F137S000", "F135S000", "F135S001", "F138S000")
names(sg)[1] = "X.U.FEFF.ID"
sg = sg[order(sg$X.U.FEFF.ID), c(1, 3, 2, 9)]
names(sg)[4] = "Year"
nodes = rbind(nodes, sg)
nodes = nodes[order(nodes$X.U.FEFF.ID),]
delidx = c("F084", "F105", "F104", "F103", "F111")
nodes = nodes[-which(nodes$X.U.FEFF.ID %in% delidx),]
nodes = drop.levels(nodes)
nodes = nodes[-2423,]
# write.csv(nodes, "deduplicated nodes.csv", row.names = FALSE)

# F137000 => F033S001
newedges = data.frame(X.U.FEFF.from = c(rep("A000", 6), "F137", "F137", "F135", "F135", "F138"), 
                      to = c("F135", "F137", "F138", "F139", "F140", "F141", "F033S001", "F137S000", "F135S000", "F135S001", "F138S000"))
edges = rbind(edges, newedges)

## check edges
# e = unique(edges$to)
# v = unique(nodes$X.U.FEFF.ID)
# (e[!(e %in% v)])

edges = edges[-which(edges$to %in% delidx),]
edges = distinct(edges)
edges = drop.levels(edges)

# write.csv(edges, "deduplicated edges.csv", fileEncoding = "UTF-8", row.names = FALSE)


#########
# Stats #
#########
## number of first-generation articles
fgnum = nodes$X.U.FEFF.ID[nchar(as.character(nodes$X.U.FEFF.ID)) <= 4]
length(fgnum) # 136 (1 is Matsuyama paper, 135 FG articles)
## number of second-generation articles
sgnum = nodes$X.U.FEFF.ID[nchar(as.character(nodes$X.U.FEFF.ID)) > 4]
length(sgnum) # 2559

## How many SG articles cite more than one FG article
df = edges[-which(edges$X.U.FEFF.from == "A000"),]
idx = which(duplicated(df$to) | duplicated(df$to, fromLast = TRUE))
df = df[idx,]
distinctid = unique(df$to)
## number of articles citing more than one FG article
length(distinctid) # 121
## number of FG articles citing more than one FG article
length(distinctid[nchar(as.character(distinctid)) <= 4]) #10
## number of SG articles citing more than one FG article
length(distinctid[nchar(as.character(distinctid)) > 4]) #111

