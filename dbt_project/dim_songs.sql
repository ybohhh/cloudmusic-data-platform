-- dbt Model: Dimension Table for Songs
-- Config: Materialize as table for performance
{{ config(materialized='table') }}

WITH raw_songs AS (
    SELECT * FROM {{ source('mysql_replica', 'songs') }}
),

raw_artists AS (
    SELECT * FROM {{ source('mysql_replica', 'artists') }}
),

final AS (
    SELECT
        s.song_id,
        s.title,
        s.duration_sec,
        CASE 
            WHEN s.duration_sec < 180 THEN 'Short'
            WHEN s.duration_sec > 300 THEN 'Long'
            ELSE 'Medium'
        END AS duration_category,
        a.artist_name,
        a.genre_primary,
        s.created_at AS ingested_at
    FROM raw_songs s
    LEFT JOIN raw_artists a ON s.artist_id = a.artist_id
)

SELECT * FROM final
