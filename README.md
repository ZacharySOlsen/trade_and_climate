# Trade and Climate
Repository for looking at how trade networks could influence incentives for joining a climate club

# Instructions
The trade_data.R file downloads data from the UN Comtrade database using its API. I have uploaded the data I got from that already so I would not do that. Downloading it all takes about an hour. The file outputs the 2023_data_from_imports.csv and the 2023_data_from_exports.csv. The data_reshaping.R files takes those two files and organizes them into adjacency matrix for graph. It outputs those changes as 2023_trade_data_matrix.csv. Finally, trade_graphs.py takes the 2023_trade_data_matrix.csv, turns it into a graph and calculates a variety of centrality measures.
