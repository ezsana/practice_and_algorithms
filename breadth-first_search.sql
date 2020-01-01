/*
 See the png file graph-full.png. This graph is directed but treat it as undirected (from-to order of nodes on edges
 doesn't matter) in your function. Edge notes describes the nature of the friendship: p means pending , a means approved,
 h means hidden , r means rejected.
 Create a PL/pgSQL function that can do breadth-first traversal from a given person. The function should return the
 accumulated number of confirmed friends of the given person.
 Confirmed friends = approved edges here.
 */

CREATE OR REPLACE FUNCTION check_pair(id1 int, id2 int) RETURNS boolean AS $$
    DECLARE
        sum_of_hits int DEFAULT 0;
    BEGIN
        SELECT count(*) INTO sum_of_hits FROM (
            SELECT * FROM friends_edges WHERE edge_point_1 = id1 AND edge_point_2 = id2
            UNION ALL
            SELECT * FROM friends_edges WHERE edge_point_1 = id2 AND edge_point_2 = id1
            ) AS pairs;
        RETURN sum_of_hits = 0;
    END;$$
    LANGUAGE plpgsql;

CREATE TEMPORARY TABLE friends_nodes (
    id int PRIMARY KEY,
    name varchar(255)
);

CREATE TEMPORARY TABLE friends_edges (
    edge_point_1 int NOT NULL REFERENCES friends_nodes(id) ON UPDATE CASCADE ON DELETE CASCADE,
    edge_point_2 int NOT NULL REFERENCES friends_nodes(id) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (edge_point_1, edge_point_2),
    CHECK ( check_pair(edge_point_1, edge_point_2) )
);

CREATE INDEX ep1_index ON friends_edges(edge_point_1);
CREATE INDEX ep2_index ON friends_edges(edge_point_2);

-- For some reason this is not working because of syntax error - but I couldn't find out why.
CREATE OR REPLACE PROCEDURE insert_values_to_friends_nodes()
LANGUAGE plpgsql
AS $$
    DECLARE
        names varchar(255) := '{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven",' ||
                                  '"twelve", "thirteen", "fourteen", "fifteen"}';
    BEGIN
        for i in 1..15 loop
            INSERT INTO friends_nodes VALUES (i, names[i]);
        end loop;
    end;$$;

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

-- This is not working either, same problem as above.
CREATE OR REPLACE PROCEDURE insert_values_to_friends_edges()
LANGUAGE plpgsql
AS $$
    DECLARE
        edge_node_pairs int[][] := '{{1,2}, {1,4}, {1,6}, {1,10}, {2,8}, {2,11}, {3,7}, {3,10}, {5,6}, {6,8},' ||
                                   ' {8,9}, {9,11}, {9,15}, {10,11}, {12,13}, {12,14}, {13,14}}';
        node_pairs int[];
    BEGIN
        foreach node_pairs slice 1 in ARRAY edge_node_pairs
        loop
            INSERT INTO friends_edges VALUES (node_pairs[1], node_pairs[2]);
        end loop;
    END;$$;

CALL insert_values_to_friends_nodes();
CALL insert_values_to_friends_edges();

/* I've used these instead of above procedures:
 INSERT INTO friends_nodes VALUES (1, 'one');
INSERT INTO friends_nodes VALUES (2, 'two');
INSERT INTO friends_nodes VALUES (3, 'three');
INSERT INTO friends_nodes VALUES (4, 'four');
INSERT INTO friends_nodes VALUES (5, 'five');
INSERT INTO friends_nodes VALUES (6, 'six');
INSERT INTO friends_nodes VALUES (7, 'seven');
INSERT INTO friends_nodes VALUES (8, 'eight');
INSERT INTO friends_nodes VALUES (9, 'nine');
INSERT INTO friends_nodes VALUES (10, 'ten');
INSERT INTO friends_nodes VALUES (11, 'eleven');
INSERT INTO friends_nodes VALUES (12, 'twelve');
INSERT INTO friends_nodes VALUES (13, 'thirteen');
INSERT INTO friends_nodes VALUES (14, 'fourteen');
INSERT INTO friends_nodes VALUES (15, 'fifteen');

INSERT INTO friends_edges VALUES (1,2);
INSERT INTO friends_edges VALUES (1,4);
INSERT INTO friends_edges VALUES (1,6);
INSERT INTO friends_edges VALUES (1,10);
INSERT INTO friends_edges VALUES (2,8);
INSERT INTO friends_edges VALUES (2,11);
INSERT INTO friends_edges VALUES (3,7);
INSERT INTO friends_edges VALUES (3,10);
INSERT INTO friends_edges VALUES (5,6);
INSERT INTO friends_edges VALUES (6,8);
INSERT INTO friends_edges VALUES (8,9);
INSERT INTO friends_edges VALUES (9,11);
INSERT INTO friends_edges VALUES (9,15);
INSERT INTO friends_edges VALUES (10,11);
INSERT INTO friends_edges VALUES (12,13);
INSERT INTO friends_edges VALUES (12,14);
INSERT INTO friends_edges VALUES (13,14);
 */

-- Function to find out the connections:

CREATE OR REPLACE FUNCTION get_connections(searched_id int) RETURNS table(vertice int) AS $$
DECLARE
    ids record;
BEGIN
    for ids in
        SELECT * FROM friends_edges WHERE edge_point_2 = searched_id OR edge_point_1 = searched_id loop
        if ids.edge_point_2 = searched_id then
            SELECT ids.edge_point_1, ids.edge_point_2 into ids.edge_point_2, ids.edge_point_1;
        end if;
        vertice := ids.edge_point_2;
        RETURN next;
    end loop;
end;$$
LANGUAGE plpgsql;
