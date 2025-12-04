-- CloudMusic Physical DDL
CREATE TABLE artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(300) NOT NULL,
    genre_primary VARCHAR(100),
    monthly_listeners INT DEFAULT 0,
    INDEX idx_artists_genre (genre_primary),
    FULLTEXT idx_artists_name (artist_name)
) ENGINE=InnoDB;

CREATE TABLE albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_title VARCHAR(500) NOT NULL,
    artist_id INT NOT NULL,
    release_date DATE,
    album_type ENUM('album', 'single', 'ep') NOT NULL,
    CONSTRAINT fk_albums_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL,
    subscription_type ENUM('free', 'premium', 'family', 'student') DEFAULT 'free',
    join_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_country (country_code),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    album_id INT NOT NULL,
    duration_sec SMALLINT UNSIGNED NOT NULL,
    genre VARCHAR(100),
    popularity_score INT DEFAULT 0,
    CONSTRAINT fk_songs_album
        FOREIGN KEY (album_id) REFERENCES albums(album_id)
        ON DELETE CASCADE,
    INDEX idx_songs_album (album_id),
    INDEX idx_songs_genre (genre),
    INDEX idx_songs_popularity (popularity_score),
    FULLTEXT idx_songs_title (title)
) ENGINE=InnoDB;

CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_type ENUM('free', 'premium_monthly', 'premium_annual', 'family', 'student'),
    start_date DATE NOT NULL,
    end_date DATE,
    price_paid DECIMAL(6,2) NOT NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_subscriptions_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CHECK (end_date IS NULL OR end_date >= start_date),
    INDEX idx_subscriptions_user (user_id),
    INDEX idx_subscriptions_dates (start_date, end_date)
) ENGINE=InnoDB;

CREATE TABLE streaming_events (
    stream_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    stream_timestamp TIMESTAMP NOT NULL,
    duration_sec SMALLINT UNSIGNED,
    completion_pct DECIMAL(5,2),
    platform ENUM('iOS', 'Android', 'Web', 'Desktop'),
    country_code CHAR(2),
    CONSTRAINT fk_stream_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_stream_song
        FOREIGN KEY (song_id) REFERENCES songs(song_id)
        ON DELETE CASCADE,
    INDEX idx_stream_user (user_id),
    INDEX idx_stream_song (song_id),
    INDEX idx_stream_user_time (user_id, stream_timestamp),
    INDEX idx_stream_song_time (song_id, stream_timestamp)
)
ENGINE=InnoDB
PARTITION BY RANGE (YEAR(stream_timestamp)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);

CREATE TABLE royalty_distributions (
    royalty_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_streams BIGINT DEFAULT 0,
    total_payment_amount DECIMAL(12,2) NOT NULL,
    payment_status ENUM('pending', 'paid') DEFAULT 'pending',
    CONSTRAINT fk_royalty_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_royalty_period UNIQUE (artist_id, period_start, period_end),
    CHECK (period_end >= period_start),
    INDEX idx_royalty_artist (artist_id),
    INDEX idx_royalty_period (period_start, period_end)
) ENGINE=InnoDB;

CREATE TABLE song_daily_streams (
    song_id INT NOT NULL,
    stream_date DATE NOT NULL,
    play_count BIGINT NOT NULL,
    PRIMARY KEY (song_id, stream_date),
    CONSTRAINT fk_daily_streams_song
        FOREIGN KEY (song_id) REFERENCES songs(song_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE artist_monthly_royalty (
    artist_id INT NOT NULL,
    month CHAR(7) NOT NULL,
    total_streams BIGINT NOT NULL,
    total_payment DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (artist_id, month),
    CONSTRAINT fk_monthly_royalty_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- PART 3: MACHINE LEARNING INTEGRATION
-- Table to store Song Popularity Predictions (Output from ML Model)
-- This closes the loop between "Wisdom" (ML) and "Action" (App)
CREATE TABLE song_popularity_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    song_id INT NOT NULL,
    prediction_date DATE NOT NULL,
    predicted_score DECIMAL(5,2), -- 0 to 100 scale
    confidence_level DECIMAL(5,4), -- e.g., 0.9500
    model_version VARCHAR(50),     -- e.g., 'rf_v1.0'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Optimization for frequent "Get latest predictions" queries
    INDEX idx_pred_date (prediction_date),
    INDEX idx_pred_song (song_id),
    
    -- Ensure data integrity
    CONSTRAINT fk_pred_song 
        FOREIGN KEY (song_id) REFERENCES songs(song_id) 
        ON DELETE CASCADE
) ENGINE=InnoDB;