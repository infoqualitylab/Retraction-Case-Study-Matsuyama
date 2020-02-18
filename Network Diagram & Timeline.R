# 2020-01-31

# load packages
library(igraph)
library(statnet)
library(ndtv) 
library(ggplot2)
library(tidyverse)

nodes = read.csv("cleaned data/nodes-2020-01-28.csv", header = TRUE, as.is=TRUE)
edges = read.csv("cleaned data/edges-2020-01-28.csv", header = TRUE, as.is=TRUE)
names(nodes)[1] = "ID"
m=as.matrix(edges)

edges = edges[, c(2, 1)]
## Data cleaning
dynamicnodes = nodes[-which(nodes$Year < 2005 |nodes$Year > 2018 | is.na(nodes$Year)),]
idx = which(nchar(as.character(dynamicnodes$ID)) <= 4)
key = dynamicnodes$ID[idx]
value = dynamicnodes$Year[idx]
names(value) = key
# write.csv(nodes[which(nodes$Year < 2005 | is.na(nodes$Year)),], "missign year.csv", row.names = FALSE)

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
dynamicedges = edges %>% filter(from %in% dynamicnodes$ID) %>% filter(to %in% dynamicnodes$ID)
################
# full network #
################
# gsnet = network(m, vertex.attr = dynamicnodes, vertex.attrnames = c("ID", "Authors", "Title", "Year"),
#                 directed = TRUE, bipartite = FALSE)
net <- graph_from_data_frame(dynamicedges, dynamicnodes, directed = T)
V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                      ifelse(V(net)$name == "A000", "black", "dimgrey"), "lightgrey")
V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                     ifelse(V(net)$name == "A000", 10, 3), 1.5)


set.seed(30)
plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
     edge.arrow.size = 0.1, 
     node.dist = 1,
     vertex.label.dist = 10,
     vertex.label = NA)


########################
# dynamic full network #
########################
## dynamic network diagram (both, second-generation articles added each year)

dynamic = function(y) {
  freq_table = dynamicnodes %>% 
    filter(Year <= y) %>% 
    group_by(group = substr(ID, 1, 4)) %>% 
    summarise(Freq = n()) 
  if (y >=2007) {
    labels = freq_table %>% 
      filter(Freq > 1 | group == "A000")
  } else {
    labels = freq_table %>% 
      filter(Freq >= 1 | group == "A000")
  }
  
  n = dynamicnodes[which(dynamicnodes$Year == y | (nchar(as.character(dynamicnodes$ID)) <= 4) & dynamicnodes$Year <= y),]
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "lightblue"), "mediumpurple")
  num_first_generation = sum(nchar(as.character(V(net)$name)) <= 4) - 1
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                       ifelse(V(net)$name == "A000", 20, 6), 3)
  set.seed(30)
  p = plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
           edge.arrow.size = 0.1, 
           # vertex.size = 12,
           vertex.label.dist = 3,
           vertex.label = NA,
           main = as.character(y),
           sub = paste0("Matsuyama Paper (black)\n", "# of first-generation articles (blue): ", 
                        num_first_generation, 
                        "\n# of second-generation articles (purple): +", 
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



###########################
# specific static network #
###########################
specific = c("A000", "F000", "F002", "F003", "F004", "F008", "F009", "F013", "F014", 
             "F015", "F016", "F022", "F026", "F027", "F030", "F037", "F039", "F045", 
             "F046", "F047", "F057", "F059", "F062", "F063", "F064", "F075", "F083", 
             "F092", "F094", "F096", "F099", "F102", "F103", "F106", "F118", "F119", 
             "F122", "F124", "F125", "F130", "F131", "F202", "F204", "F205", "F206", 
             "F207", "F208", "F209", "F302", "F303")

## First-generation specific citations
snodes = nodes[(nodes$ID %in% specific),]
sedges = edges[((edges$from %in% snodes$ID) & (edges$to %in% snodes$ID)),]


############################
# specific dynamic network #
############################
## dynamic network diagram (both, second-generation articles added each year)

dynamic_specific = function(y, dynamicnodes) {
  freq_table = dynamicnodes %>%
    filter(Year <= y) %>%
    group_by(group = substr(ID, 1, 4)) %>%
    summarise(Freq = n())
  if (y >=2007) {
    labels = freq_table %>%
      filter(Freq > 1 | group == "A000")
  } else {
    labels = freq_table %>%
      filter(Freq >= 1 | group == "A000")
  }
  
  n = dynamicnodes[which(dynamicnodes$Year == y | (nchar(as.character(dynamicnodes$ID)) <= 4) & dynamicnodes$Year <= y),]
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4),
                        ifelse(V(net)$name == "A000", "black", "lightblue"), "mediumpurple")
  num_first_generation = sum(nchar(as.character(V(net)$name)) <= 4) - 1
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  # V(net)$size = ifelse(V(net)$name == "A000", 24, 10)
  V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                       ifelse(V(net)$name == "A000", 20, 6), 3)
  set.seed(30)
  p = plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
           edge.arrow.size = 0.1,
           vertex.label.dist = 3,
           vertex.label = NA,
           main = as.character(y),
           sub = paste0("Matsuyama Paper (black)\n", "# of first-generation articles (blue): ",
                        num_first_generation,
                        "\n# of second-generation articles (purple): +",
                        num_second_generation))
  return(p)
}

snodes = dynamicnodes[((dynamicnodes$ID %in% specific) | substr(as.character(dynamicnodes$ID), 1, 4) %in% specific),]
sedges = edges[((edges$from %in% snodes$ID) | (edges$to %in% snodes$ID)),]

par(mfrow = c(2, 2))
for(i in 2005:2008) {
  dynamic_specific(i, snodes)
}
par(mfrow = c(2, 2))
for(i in 2009:2018) {
  dynamic_specific(i, snodes)
}


###### #########
# highly cited #
################
specific = c("A000", "F000", "F002", "F003", "F004", "F008", "F009", "F013", "F014", 
             "F015", "F016", "F022", "F026", "F027", "F030", "F037", "F039", "F045", 
             "F046", "F047", "F057", "F059", "F062", "F063", "F064", "F075", "F083", 
             "F092", "F094", "F096", "F099", "F102", "F103", "F106", "F118", "F119", 
             "F122", "F124", "F125", "F130", "F131", "F202", "F204", "F205", "F206", 
             "F207", "F208", "F209", "F302", "F303")

hc_nodes = dynamicnodes[dynamicnodes$ID %in% specific,]
hc_nodes = hc_nodes[, c(1, 4)]
hc_edges = edges[edges$from %in% specific,]
freq = hc_edges %>% 
  mutate(ID = from) %>% 
  select(ID) %>% 
  group_by(ID) %>% 
  summarise(Freq = n())
total = merge(hc_nodes,freq,by="ID")
total = total %>% mutate(duration = 2018 - Year) %>% 
  mutate(avg = Freq/duration) %>% 
  mutate(select = ifelse(avg >= 5, 1, 0))
hc_fg_specific = total[total$select == 1,]
hc_fg_specific = hc_fg_specific$ID
hc_edges = edges[edges$from %in% hc_fg_specific,]
hc_nodes = unique(append(hc_edges$from, hc_edges$to))
hc_nodes = dynamicnodes[dynamicnodes$ID %in% hc_nodes,]

net2 <- graph_from_data_frame(hc_edges, hc_nodes, directed = T)
V(net2)$color = ifelse((nchar(as.character(V(net2)$name)) <= 4), 
                      ifelse(V(net2)$name == "A000", "black", "lightblue"), "purple")
V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                     ifelse(V(net)$name == "A000", 10, 3), 1.5)
set.seed(30)
plot(net2, layout = layout_with_fr, 
     edge.arrow.size = 0.5, 
     vertex.size = 4,
     vertex.label.dist = 2,
     vertex.label = NA)



####################################
# post retraction specific network #
####################################
post_specific = nodes[nodes$ID %in% specific, ]
# post_specific = post_specific[(post_specific$Year >= 2010 & post_specific$Year <= 2018),]
post_specific = post_specific[(post_specific$Year >= 2010 & post_specific$Year <= 2018) | post_specific$ID == "A000",]
post_specific = post_specific$ID

range_nodes = dynamicnodes %>% filter(Year <= 2018) %>% filter(Year >= 2010)
sedges = edges %>% filter((to != "A000" & to %in% post_specific & from %in% range_nodes$ID) | (to == "A000" & from %in% post_specific))
snodes = dynamicnodes %>% filter(ID %in% sedges$from | ID %in% sedges$to)

net3 <- graph_from_data_frame(sedges, snodes, directed = T)
V(net3)$color = ifelse((nchar(as.character(V(net3)$name)) <= 4), 
                       ifelse(V(net3)$name == "A000", "black", "lightblue"), "mediumpurple")
set.seed(23)
plot(net3, layout = layout_with_lgl, 
     edge.arrow.size = 0.5, 
     vertex.size = 4,
     vertex.label.dist = 2,
     vertex.label = NA)





## timeline
library(ggplot2)
library(tidyverse)
time_nodes = nodes %>% filter(nchar(ID) == 4) %>% filter(ID != "A000") %>% group_by(Year) %>% summarise(Freq = n())
retraction_citations = time_nodes$Freq
years = seq(2006, 2018, 1)
citations = factor(c(rep("pre-retraction citations", 3), "Washout period citations", rep("post-retraction citations", 9)))
time_line = data.frame(years, retraction_citations, citations)
# Plot

ggplot(time_line) +
  geom_line(aes(x=years, y=retraction_citations), size = 1, alpha = 0.3, linetype = 1) +
  geom_point(aes(x=years, y=retraction_citations, color = citations), size = 4) +
  scale_color_manual(values=c("red", "blue", "gray")) + 
  scale_x_continuous(breaks = 2006:2018) +
  geom_text(aes(x=years, y=retraction_citations, label = retraction_citations),
            vjust = -0.5, hjust = -0.5, size = 4, show.legend = FALSE) + 
  labs(title="Number of retraction citations to the Matsuyama paper by Year",
       x ="Year", y = "Number of citations", 
       subtitle = "blue for pre-retraction citations from 2006-October 2008; \ngrey for washout period citations October 2008-December 2009; \nred for post-retraction citations 2010-2019.")
