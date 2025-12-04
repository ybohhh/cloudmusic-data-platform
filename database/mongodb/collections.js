// CloudMusic MongoDB Schema Design
// Focus: User Profiles (Unstructured preferences) & Playlists

// 1. User Profiles Collection
db.createCollection("user_profiles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "preferences"],
      properties: {
        user_id: { bsonType: "int", description: "Matches MySQL user_id" },
        preferences: {
          bsonType: "object",
          required: ["preferred_genres", "autoplay_enabled"],
          properties: {
            preferred_genres: { bsonType: "array", items: { bsonType: "string" } },
            autoplay_enabled: { bsonType: "bool" }
          }
        },
        listening_history_summary: { bsonType: "array" } // Embedded document example
      }
    }
  }
});

// Indexes for high-speed lookup
db.user_profiles.createIndex({ "user_id": 1 }, { unique: true });
db.user_profiles.createIndex({ "preferences.preferred_genres": 1 });

// 2. Playlists Collection (Nested structure example)
db.createCollection("playlists");
db.playlists.createIndex({ "owner_id": 1 });
db.playlists.createIndex({ "tags": 1 });

print("✅ MongoDB Collections and Indexes created successfully.");
