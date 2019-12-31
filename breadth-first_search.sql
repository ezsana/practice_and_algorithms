/*
 See the png file graph-full.png. This graph is directed but treat it as undirected (from-to order of nodes on edges
 doesn't matter) in your function. Edge notes describes the nature of the friendship: p means pending , a means approved,
 h means hidden , r means rejected.
 Create a PL/pgSQL function that can do breadth-first traversal from a given person. The function should return the
 accumulated number of confirmed friends of the given person.
 Confirmed friends = approved edges here.
 */

/*
 Adjacency list of the graph:
 1 -> 2 - 4 - 6 - 10;
 2 -> 1 - 8 - 11;
 3 -> 7 - 10;
 4 -> 1;
 5 -> 6;
 6 -> 1 - 5 - 8;
 7 -> 3;
 8 -> 2 - 6 - 9;
 9 -> 8 - 11 - 15;
 10 -> 1 - 3 - 11;
 11 -> 2 - 9 - 10;
 12 -> 13 - 14;
 13 -> 12 - 14;
 14 -> 12 - 13;
 15 -> 9;
 */

