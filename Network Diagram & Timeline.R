# 2020-06-18

# load packages
library(igraph)
library(ggplot2)
library(tidyverse)

# read data
nodes = read.csv("cleaned data/nodes.csv", header = TRUE, as.is=TRUE)
edges = read.csv("cleaned data/edges.csv", header = TRUE, as.is=TRUE)
names(nodes)[1] = "ID"
m=as.matrix(edges)

## Data cleaning
sum(is.na(nodes$Year))
dynamicnodes = nodes[-which(nodes$Year < 2005 |nodes$Year > 2019 | is.na(nodes$Year)),]
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
dynamicedges = edges %>% filter(from %in% dynamicnodes$ID) %>% filter(to %in% dynamicnodes$ID)

# output = dynamicnodes[unreasonable.idx,]
# write.csv(output, "unreasonable year.csv", row.names = FALSE)

###########################
# FULL NETWORK (FIGURE 4) #
###########################
net <- graph_from_data_frame(dynamicedges, dynamicnodes, directed = T)
# color
V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                      ifelse(V(net)$name == "A000", "black", "blue"), "red")
# shape
V(net)$shape = ifelse((nchar(as.character(V(net)$name)) <= 4),
                      ifelse(V(net)$name == "A000", 'sphere', 'square'), 'circle')
# size
V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                     ifelse(V(net)$name == "A000", 10, 3), 1.5)


set.seed(29)
plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
     edge.arrow.size = 0.1, 
     node.dist = 1,
     vertex.label.dist = 10,
     vertex.label = NA)


########################
# DYNAMIC FULL NETWORK #
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
  # color
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "blue"), "red")
  # shape
  V(net)$shape = ifelse((nchar(as.character(V(net)$name)) <= 4),
                        ifelse(V(net)$name == "A000", 'sphere', 'square'), 'circle')
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
par(mfrow = c(3, 3))
for(i in 2006:2008) {
  dynamic(i)
}
par(mfrow = c(4, 3))
for(i in 2009:2019) {
  dynamic(i)
}



###########################
# specific static network #
###########################
specific = c("F000", "F002", "F003", "F004", "F008", "F009", "F013", "F014", "F015", "F016", 
              "F022", "F026", "F027", "F030", "F037", "F039", "F045", "F046", "F047", "F057", 
              "F059", "F062", "F063", "F064", "F075", "F078", "F083", "F092", "F094", "F096", 
              "F099", "F102", "F103", "F106", "F110", "F112", "F118", "F119", "F120", "F122", 
              "F123", "F124", "F125", "F130", "F131", "F138", "F140", "F202", "F204", "F205", 
              "F206", "F207", "F208", "F209", "F302", "F303", "F400", "F403", "F405", "F406", "A000")

#2010-2019 specific citations
post_specific = c("F009", "F015", "F026", "F030", "F045", "F047", "F057", "F059", "F063",
                  "F064", "F075", "F078", "F083", "F094", "F102", "F106", "F118", "F119",
                  "F120", "F122", "F123", "F124", "F125", "F130", "F140", "F204", "F205", 
                  "F207", "F208", "F209", "F303", "F400", "F403", "F405", "F406", "A000")
#######################################
# SPECIFIC DYNAMIC NETWORK (FIGURE 5) #
#######################################
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
  # color
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "blue"), "red")
  # shape
  V(net)$shape = ifelse((nchar(as.character(V(net)$name)) <= 4),
                        ifelse(V(net)$name == "A000", 'sphere', 'square'), 'circle')
  
  num_first_generation = sum(as.character(V(net)$name) %in% specific) - 1
  other_first_generation = sum((!(as.character(V(net)$name) %in% specific) & nchar(V(net)$name) == 4))
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4),
                       ifelse(V(net)$name == "A000", 20, 7), 5)
  set.seed(30)
  p = plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
           edge.arrow.size = 0.1,
           vertex.label.dist = 3,
           vertex.label = NA,
           main = as.character(y),
           sub = paste0("Matsuyama Paper (black)\n", "# of specific first-generation articles (blue): ",
                        num_first_generation,
                        "\n # of other first-generation articles (citing; blue): ",
                        other_first_generation,
                        "\n# of second-generation articles (purple): +",
                        num_second_generation))
  return(p)
}

sedges = edges[((edges$to %in% specific[1:length(post_specific)-1]) | (edges$to %in% specific & edges$from == 'A000')),]
snodes = dynamicnodes[(dynamicnodes$ID %in% sedges$from | dynamicnodes$ID %in% sedges$to | dynamicnodes$ID %in% specific),]

par(mfrow = c(3, 3))
for(i in 2006:2008) {
  dynamic_specific(i, snodes)
}
par(mfrow = c(4, 3))
for(i in 2009:2019) {
  dynamic_specific(i, snodes)
}


########################################
# SPECIFIC WHOLE SG NETWORK (FIGURE 8) #
########################################
# 2019
dynamic_specific = function(y, dynamicnodes, seed_number) {
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
  
  n = dynamicnodes[which(dynamicnodes$Year <= y),]
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  # color
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "blue"), "red")
  # shape
  V(net)$shape = ifelse((nchar(as.character(V(net)$name)) <= 4),
                        ifelse(V(net)$name == "A000", 'sphere', 'square'), 'circle')
  num_first_generation = sum(as.character(V(net)$name) %in% specific) - 1
  other_first_generation = sum((!(as.character(V(net)$name) %in% specific) & nchar(V(net)$name) == 4))
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                       ifelse(V(net)$name == "A000", 10, 3), 1.5)
  set.seed(seed_number)
  p = plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
           edge.arrow.size = 0.1,
           vertex.label.dist = 10,
           vertex.label = NA,
           main = as.character(y),
           sub = paste0("Matsuyama Paper (black)\n", "# of specific first-generation articles (blue): ",
                        num_first_generation,
                        "\n # of other first-generation articles (citing; blue): ",
                        other_first_generation,
                        "\n# of second-generation articles (purple): ",
                        num_second_generation))
  return(p)
}

par(mfrow = c(1, 1))
sedges = edges[((edges$to %in% specific[1:length(post_specific)-1]) | (edges$to %in% specific & edges$from == 'A000')),]
snodes = dynamicnodes[(dynamicnodes$ID %in% sedges$from | dynamicnodes$ID %in% sedges$to | dynamicnodes$ID %in% specific),]

dynamic_specific(2019, snodes, 30)







###############################################
# POST RETRACTION SPECIFIC NETWORK (FIGURE 9) #
###############################################
dynamic_post_specific = function(y, dynamicnodes, seed_number) {
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
  
  n = dynamicnodes[which(dynamicnodes$Year <= y),]
  e = edges[((edges$from %in% n$ID) & (edges$to %in% n$ID)),]
  net = graph_from_data_frame(e, n, directed = T)
  # color
  V(net)$color = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                        ifelse(V(net)$name == "A000", "black", "blue"), "red")
  # shape
  V(net)$shape = ifelse((nchar(as.character(V(net)$name)) <= 4),
                        ifelse(V(net)$name == "A000", 'sphere', 'square'), 'circle')
  num_first_generation = sum(as.character(V(net)$name) %in% post_specific) - 1
  other_first_generation = sum((!(as.character(V(net)$name) %in% post_specific) & nchar(V(net)$name) == 4))
  num_second_generation = sum(nchar(as.character(V(net)$name)) > 4)
  V(net)$size = ifelse((nchar(as.character(V(net)$name)) <= 4), 
                       ifelse(V(net)$name == "A000", 10, 3), 1.5)
  set.seed(seed_number)
  p = plot(net, layout = layout.fruchterman.reingold, rescale = TRUE,
           edge.arrow.size = 0.1,
           vertex.label.dist = 10,
           vertex.label = NA,
           main = "Specific citation 2010-2019",
           sub = paste0("Matsuyama Paper (black)\n", "# of specific first-generation articles (blue): ",
                        num_first_generation,
                        "\n # of other first-generation articles (citing; blue): ",
                        other_first_generation,
                        "\n# of second-generation articles (purple): ",
                        num_second_generation))
  return(p)
}


sedges = edges[((edges$to %in% post_specific[1:length(post_specific)-1]) | (edges$to %in% post_specific & edges$from == 'A000')),]
snodes = dynamicnodes[(dynamicnodes$ID %in% sedges$from | dynamicnodes$ID %in% sedges$to | dynamicnodes$ID %in% post_specific),]
par(mfrow = c(1, 1))
dynamic_post_specific(2019, snodes, 30)






# correct check
sedges$check = ifelse(as.character(sedges$to) == substr(as.character(sedges$from), 1, 4), 1, 0)
# unique first-generation
sum(!(unique(sedges$from[sedges$check == 0 & nchar(sedges$from) == 4]) %in% post_specific))
# unique second-generation
sum(!(unique(sedges$from[sedges$check == 0 & nchar(sedges$from) != 4]) %in% post_specific))
# normal citations
length(unique(sedges$from[sedges$check == 1]))
# total unique citations
length(unique(sedges$from))
# total sg citations
length(sedges$from[nchar(sedges$from) != 4])


#######################
# TIMELINE (FIGURE 2) #
#######################
library(ggplot2)
library(tidyverse)
time_nodes = nodes %>% filter(nchar(ID) == 4) %>% filter(ID != "A000") %>% group_by(Year) %>% summarise(Freq = n())
retraction_citations = time_nodes$Freq
years = seq(2006, 2019, 1)
citations = factor(c(rep("Pre-retraction citations", 3), rep("Post-retraction citations", 11)))
time_line = data.frame(years, retraction_citations, citations)

# time_line <- rbind(data.frame(years = 2008, retraction_citations = 10, citations = "Washout period citations"), time_line)
time_line <- rbind(data.frame(years = 2009, retraction_citations = 22, citations = "Pre-retraction citations"), time_line)
ggplot(time_line) +
  geom_line(aes(x=years, y=retraction_citations, color = citations), size = 1, alpha = 0.3, linetype = 1) +
  geom_point(aes(x=years, y=retraction_citations, color = citations), size = 4) +
  scale_color_manual(values=c("blue", "red")) + 
  scale_x_continuous(breaks = 2006:2019) +
  geom_text(aes(x=years, y=retraction_citations, label = retraction_citations),
            vjust = -0.5, hjust = -0.5, size = 4, show.legend = FALSE) + 
  labs(title="Number of retraction citations to the Matsuyama paper by Year",
       x ="Year", y = "Number of citations", 
       subtitle = "blue for pre-retraction citations from 2006-October 2008; \nred for post-retraction citations 2009-2019.")
