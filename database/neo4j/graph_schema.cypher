// CloudMusic Graph Schema
// Focus: Social Network & Recommendation Constraints

// 1. Create Constraints (Schema enforcement)
CREATE CONSTRAINT user_id_unique IF NOT EXISTS FOR (u:User) REQUIRE u.user_id IS UNIQUE;
CREATE CONSTRAINT artist_id_unique IF NOT EXISTS FOR (a:Artist) REQUIRE a.artist_id IS UNIQUE;

// 2. Sample Data Structure (Comments explaining relationships)
/*
Nodes:
  (:User {user_id: 101, name: "Alice"})
  (:Artist {artist_id: 5, name: "The Weeknd"})
  (:Song {song_id: 200, title: "Blinding Lights"})

Relationships:
  (:User)-[:FOLLOWS]->(:User)
  (:User)-[:LIKES]->(:Artist)
  (:User)-[:STREAMED {count: 50}]->(:Song)
*/

// 3. Recommendation Algorithm Query (Sample)
// "Find artists liked by people who follow me"
// MATCH (me:User {user_id: $uid})-[:FOLLOWS]->(friend:User)-[:LIKES]->(rec_artist:Artist)
// WHERE NOT (me)-[:LIKES]->(rec_artist)
// RETURN rec_artist.name, COUNT(friend) as score
// ORDER BY score DESC;
