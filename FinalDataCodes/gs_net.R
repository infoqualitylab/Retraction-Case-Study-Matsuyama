# install.packages("igraph")
library(igraph)
# install.packages("statnet")
library(statnet)
# install.packages("ndtv")
library(ndtv) 
# install.packages("ggplot2")
library(ggplot2)
# install.packages("tidyverse")
library(tidyverse)

## import edgelist
edges=read.csv("deduplicated edges.csv",header=TRUE)
names(edges)[1] = "from"
edges = edges[, c(2, 1)]
names(edges) = c("from", "to")
# write.csv(edges, "deduplicated edges.csv", row.names = FALSE)
# write.csv(nodes, "deduplicated nodes.csv", row.names = FALSE)
m=as.matrix(edges)

## import nodeslist (should be same dimension as edgelist)
nodes=read.csv('deduplicated nodes.csv', header=TRUE, as.is=TRUE)
names(nodes)[1] = "ID"

# vertex.attrnames should match exactly with headings in nodeslist 
gsnet = network(m, vertex.attr = nodes, vertex.attrnames = c("ID", "Authors", "Title", "Year"),
                directed = TRUE, bipartite = FALSE)

# plotting to see what the static network looks like 
net2 <- graph_from_data_frame(edges, nodes, directed = T)
V(net2)$color = ifelse((nchar(as.character(V(net2)$name)) <= 4), 
                       ifelse(V(net2)$name == "A000", "black", "lightblue"), "mediumpurple")

set.seed(23)
plot(net2, layout = layout_with_lgl, 
     edge.arrow.size = 0.5, 
     vertex.size = 4,
     vertex.label.dist = 2,
     vertex.label = NA)

# specific
specific = c("A000", "F045", "F057", "F015", "F130",
             "F119", "F083", "F106", "F061", "F085",
             "F059", "F102", "F122", "F125")
snodes = nodes[((nodes$ID %in% specific) | substr(as.character(nodes$ID), 1, 4) %in% specific),]
sedges = edges[((edges$from %in% snodes$ID) & (edges$to %in% snodes$ID)),]
net3 <- graph_from_data_frame(sedges, snodes, directed = T)
V(net3)$color = ifelse((nchar(as.character(V(net3)$name)) <= 4), 
                       ifelse(V(net3)$name == "A000", "black", "lightblue"), "mediumpurple")
set.seed(23)
plot(net3, layout = layout_with_lgl, 
     edge.arrow.size = 0.5, 
     vertex.size = 4,
     vertex.label.dist = 2,
     vertex.label = NA)
snodes = nodes[(nodes$ID %in% specific),]
sedges = edges[((edges$from %in% snodes$ID) & (edges$to %in% snodes$ID)),]
net4 <- graph_from_data_frame(sedges, snodes, directed = T)
V(net4)$color = ifelse((nchar(as.character(V(net4)$name)) <= 4), 
                       ifelse(V(net4)$name == "A000", "black", "lightblue"), "mediumpurple")
set.seed(23)
plot(net4, layout = layout_with_lgl, 
     edge.arrow.size = 0.5, 
     vertex.size = 4,
     vertex.label.dist = 2,
     vertex.label = NA)

## clean up nodes and edges for dynamic network
## exclude publication year smaller than 2005 or unavailable publication year
dynamicnodes = nodes[-which(nodes$Year < 2005 | is.na(nodes$Year)),]
dynamicnodes = dynamicnodes[-which(dynamicnodes$ID == "F063S001"),]
idx = which(nchar(as.character(dynamicnodes$ID)) <= 4)
key = dynamicnodes$ID[idx]
value = dynamicnodes$Year[idx]
names(value) = key

## exclude SG publications with year before FG publication year
unreasonable.idx = c()
for (i in 1:nrow(dynamicnodes)) {
  if(nchar(as.character(dynamicnodes$ID[i] > 4))) {
    fgid = substr(as.character(dynamicnodes$ID[i]), 1, 4)
    fgyear = value[[fgid]]
    if(dynamicnodes$Year[i] < fgyear) {
      unreasonable.idx = c(unreasonable.idx, i)
    }
  }
}
dynamicnodes = dynamicnodes[-unreasonable.idx,]

## updated: 12/04/2019
## dynamic network diagram (both)
dynamic = function(y) {
  n = dynamicnodes[which(dynamicnodes$Year <= y),]
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                         ifelse(V(net)$name == "A000", "black", "lightblue"), "mediumpurple")
  num_first_generation = sum(nchar(as.character(V(net)$name)) <= 4) - 1
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  p = plot(net, layout = layout_with_lgl, 
               edge.arrow.size = 0.5, 
               vertex.size = 12,
               vertex.label.dist = 2,
               vertex.label = NA,
               main = as.character(y),
               sub = paste("Matsuyama Paper (black)\n", "# of first-generation articles (blue):", 
                           num_first_generation, 
                           "\n# of second-generation articles (purple):", 
                           num_second_generation))
  return(p)
}
par(mfrow = c(2, 2))
for(i in 2005:2008) {
  dynamic(i)
}
par(mfrow = c(2, 2))
for(i in 2009:2018) {
  dynamic(i)
}

## dynamic network diagram (fg)
dynamicnodes1 = dynamicnodes[which(nchar(as.character(dynamicnodes$ID)) <= 4),]

dynamic1 = function(y) {
  n = dynamicnodes1[which(dynamicnodes1$Year <= y),]
  print(nrow(n))
  print(n$ID)
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "lightblue"), "mediumpurple")
  p = plot(net, layout = layout_with_lgl, 
           edge.arrow.size = 0.5, 
           vertex.size = 10,
           vertex.label.dist = 2,
           vertex.label = NA,
           main = as.character(y))
  return(p)
}
par(mfrow = c(2, 2))
for(i in 2005:2008) {
  dynamic1(i)
}
par(mfrow = c(2, 2))
for(i in 2009:2018) {
  dynamic1(i)
}

## timeline
retraction_citations = c(1, 9, 9, 9,
                         19, 6, 10, 19,
                         9, 6, 10, 7, 4, 4)
years = seq(2005, 2018, 1)
group = c(rep(1, 4), rep(2, 10))
timeline = data.frame(years, retraction_citations, group)
# Plot
ggplot(timeline, aes(x=years, y=retraction_citations, color = group)) +
  geom_line(size = 1.5, alpha = 0.5, linetype = 1) +
  geom_point(size = 3) +
  geom_text(aes(label = retraction_citations),
            vjust = -0.5, hjust = -0.5, size = 4, show.legend = FALSE) +
  labs(title="Number of retraction citations to the Matsuyama paper by Year",
       x ="Year", y = "Retraction Citations", 
       subtitle = "Pre-retraction 2005 - 2008 (red) & Post-retraction 2009 - 2018 (blue)") +
  scale_color_gradient(low = "#F8766D", high = "#56B1F7") +
  theme(legend.position = "none")

## highly-cited FG articles
highly_cited = edges %>% group_by(from) %>% count(from) %>% filter(n >= 40)













# Ly's code
# try with the modified Fructerman-Reignold setting
fr = layout.fruchterman.reingold(net, niter=5000, area=vcount(net)^4*10)
plot(edges, layout=fr, 
     edge.arrow.size=0.5, 
     vertex.label=NA,
     vertex.shape="circle", 
     vertex.size=1, 
     vertex.label.color="black", 
     edge.width=0.5)

### Converting static net to dynamic network edges and nodes
#tail = source IDs (from, outgoing)
#head = target IDs (to, incoming)
#onset = starting time
# terminus = ending time 
GS_Dynamidynamicnodes = read.csv('Ly code/GS_Dynamidynamicnodes.csv',header=TRUE,as.is=TRUE)
GS_DynamicEdges = read.csv('Ly code/GS_DynamicEdges.csv',header=TRUE,as.is=TRUE)

# create dynamic network object
GS_DynamicNet = networkDynamic(gs_net,
                               edge.spells = GS_DynamicEdges2,
                               vertex.spells = GS_Dynamidynamicnodes2)

# check if net is dynamic 
network.dynamic.check(GS_DynamicNet)

# create a filmstrip that displays a subset of time intervals 
filmstrip(GS_DynamicNet, displaylabels = FALSE)

# To create an animated version of the network, we first execute compute.animation; this is function in ndtv that helps determine optimal calculation for network animation
compute.animation(
  dynamicCollabs,
  animation.mode = "kamadakawai",
  slice.par = list(
    start = 2005,  # start date from the citation year of the original retracted paper
    end = 2019, 
    interval = 1,  # capture change for every 1 year 
    aggregate.dur = 5,  # aggregate edges shown for periods of every 5 years 
    rule = "any"
  )
)

# Render the animation and open it in a web brower
render.d3movie(
  dynamicCollabs,
  displaylabels = FALSE,
  # This slice function makes the labels work
  vertex.tooltip = function(slice) {  ## function slide from slice.par determined above 
    paste(
      "<b>ID:</b>", (slice %v% "ID"),
      "<br>",
      "<b>Title:</b>", (slice %v% "Title")
    )
  }
)