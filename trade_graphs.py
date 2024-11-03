# Loading Packages.
import numpy as np
import scipy
import matplotlib.pyplot as plt
from networkx.drawing.nx_agraph import graphviz_layout
import networkx as nx
import pandas as pd
import os

import scipy.sparse
import scipy.sparse.linalg

# Setting working directory.

# Loading the data.
trade_data_matrix = pd.read_csv("2023_trade_data_matrix.csv")

# Splitting into vertices and edges.
vertices = trade_data_matrix.iloc[:, 0].values
edges = trade_data_matrix.iloc[:, 1:].values

# Creating a directed graph
G = nx.DiGraph()

# Adding nodes
for vertex in vertices:
    G.add_node(vertex)

# Adding weighted edges based on the matrix, reversing direction since row i corresponds to the destination of the edge while column j
# is the origin of the edge.
for i, destination in enumerate(vertices):
    for j, origin in enumerate(vertices):
        weight = edges[i, j]
        if weight != 0:  # Optional: only add edges with non-zero weights
            G.add_edge(origin, destination, weight=weight)

# Display basic graph information
# print("Number of nodes:", G.number_of_nodes())
# print("Number of edges:", G.number_of_edges())
# print("Graph edges with weights:", G.edges(data=True))



plt.figure(figsize=(16, 12))

# Use Graphviz layout (e.g., 'dot', 'neato', 'sfdp')
pos = graphviz_layout(G, prog="sfdp")  # Try 'dot' or 'neato' if 'sfdp' doesn't work well

# Draw edges with widths proportional to weights
edge_weights = nx.get_edge_attributes(G, 'weight')
max_weight = max(edge_weights.values())
min_weight = min(edge_weights.values())
edge_widths = [
    0.5 + 4.5 * (weight - min_weight) / (max_weight - min_weight)  # Normalize to range [0.5, 5]
    for weight in edge_weights.values()
]

# Draw nodes and edges with Graphviz layout
nx.draw_networkx_nodes(G, pos, node_size=800, node_color="lightblue", edgecolors="black")
nx.draw_networkx_labels(G, pos, font_size=10, font_color="black")
nx.draw_networkx_edges(G, pos, arrowstyle="->", arrowsize=20, edge_color="gray", width=edge_widths)

plt.title("Directed Weighted Graph with Graphviz Layout")
plt.axis("off")
plt.show()

# Checking if G is strongly connected. Want to check because that implies that the Adjacency matrix is irreducible.
nx.is_strongly_connected(G)

# Eigenvector Centrality.
centrality = nx.eigenvector_centrality(G)

sorted_centrality = dict(sorted(centrality.items(), key=lambda item: item[1], reverse=True))

# Extract node names and their centrality values
nodes = list(sorted_centrality.keys())
centrality_scores = list(sorted_centrality.values())

# Plot the bar graph
plt.figure(figsize=(10, 40))
plt.barh(nodes, centrality_scores, color="skyblue")
plt.ylabel("Countries (ISO Code 3)")
plt.xlabel("Eigenvector Centrality")
plt.title("Eigenvector Centrality for Trade 2023")
plt.show()
plt.savefig("eigenvector_centrality.png")

# Hub and authority Centrality
hub_and_authority = nx.hits(G)

hub = hub_and_authority[0]
authority = hub_and_authority[1]

# Creating graphs for both of these.
sorted_hub = dict(sorted(hub.items(), key=lambda item: item[1], reverse=True))
sorted_authority = dict(sorted(authority.items(), key=lambda item: item[1], reverse=True))

# Node Names
nodes_h = list(sorted_hub.keys())
nodes_a = list(sorted_authority.keys())

# Centrality Values
hub_score = list(sorted_hub.values())
authority_score = list(sorted_authority.values())

# Plotting Bar Graphs
plt.figure(figsize=(10, 40))
plt.barh(nodes_h, hub_score, color = "skyblue")
plt.ylabel("Countries (ISO Code 3)")
plt.xlabel("Hub Centrality")
plt.title("Hub Centrality for Trade in 2023")
plt.show()
plt.savefig("hub_centrality.png")

plt.figure(figsize=(10, 40))
plt.barh(nodes_a, authority_score, color = "skyblue")
plt.ylabel("Countries (ISO Code 3)")
plt.xlabel("Authority Centrality")
plt.title("Authority Centrality for Trade in 2023")
plt.show()
plt.savefig("authority_centrality.png")