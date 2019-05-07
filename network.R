# install.packages("igraph")
library(igraph)
path_to_dir <- ""
# GS_path <- paste0(path_to_dir, "GS SEARCH/")
# WOS_path <- paste0(path_to_dir, "WOS SEARCH/Matsuyama/")


edges <- read.csv(paste0(path_to_dir, 'GS edges.csv'))
edges <- edges[-116,] # duplicated edge
nodes <- read.csv(paste0(path_to_dir, 'GS nodes.csv'), encoding = 'UTF-8')
nodes <- nodes[-117,] # duplicated node

# second-generation
routes_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)
g <- graph.data.frame(edges, directed=FALSE, vertices=nodes)
# plot(g)
plot(g, layout=layout_with_fr, vertex.size=4,
     vertex.label.dist=2, vertex.color="red", edge.arrow.size=0.5)

# first-generation
edges <- edges[1:134,]
nodes <- nodes[1:135,]
g <- graph.data.frame(edges, directed=FALSE, vertices=nodes)
V(g)$color <- ifelse(V(g) == V(g)[1], "blue", "red")
plot(g, layout=layout.fruchterman.reingold, vertex.color=V(g)$color, layout=layout_with_fr, vertex.size=10,
          vertex.label.dist=2, edge.arrow.size=0.5)
