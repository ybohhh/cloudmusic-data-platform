"""
CloudMusic Database Project - Part 3: Machine Learning Model

Description: 
This script simulates the pipeline that:
1. Extracts features from the Data Warehouse (Redshift/MySQL).
2. Trains a Random Forest Regressor to predict 'popularity_score'.
3. Evaluates model performance using RMSE.
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# ==========================================
# 1. Data Loading (Simulating SQL Extraction)
# ==========================================
# In production, this would connect to Redshift:
# df = pd.read_sql("SELECT * FROM ml_training_features", conn)

print("Loading training data...")
data = {
    'song_id': range(1, 101),
    # Feature: Audio Analysis (from S3)
    'tempo': np.random.normal(120, 10, 100),
    'energy': np.random.uniform(0, 1, 100),
    'danceability': np.random.uniform(0, 1, 100),
    
    # Feature: Artist Metrics (from Neo4j/MySQL)
    'artist_followers': np.random.randint(1000, 1000000, 100),
    
    # Feature: Early Performance (from MySQL streaming_events)
    'first_24h_streams': np.random.randint(100, 50000, 100),
    'completion_rate': np.random.uniform(0.4, 0.9, 100),
    
    # Feature: Metadata
    'genre': np.random.choice(['Pop', 'Hip-Hop', 'Rock', 'Indie'], 100),
    
    # TARGET VARIABLE (What we want to predict)
    # Logic: Higher streams + high energy = Higher Popularity
    'popularity_score_day_7': np.random.randint(10, 100, 100) 
}

df = pd.DataFrame(data)

# ==========================================
# 2. Feature Engineering
# ==========================================
print("Engineering features...")

# One-Hot Encoding for Categorical 'genre'
df_processed = pd.get_dummies(df, columns=['genre'], drop_first=True)

# Define X (Features) and y (Target)
features = df_processed.drop(['song_id', 'popularity_score_day_7'], axis=1)
target = df_processed['popularity_score_day_7']

# Split Data (80% Train, 20% Test)
X_train, X_test, y_train, y_test = train_test_split(
    features, target, test_size=0.2, random_state=42
)

# ==========================================
# 3. Model Training (Random Forest)
# ==========================================
print(f"Training Random Forest on {len(X_train)} songs...")

# Initialize Model
# Rationale: Random Forest handles non-linear relationships better than Linear Regression
rf_model = RandomForestRegressor(
    n_estimators=100,
    max_depth=10,
    random_state=42
)

# Fit Model
rf_model.fit(X_train, y_train)

# ==========================================
# 4. Evaluation
# ==========================================
print("Evaluating model...")

predictions = rf_model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test, predictions))
r2 = r2_score(y_test, predictions)

print(f"Model Results:")
print(f"RMSE: {rmse:.2f} (lower is better)")
print(f"R² Score: {r2:.2f}")

# ==========================================
# 5. Feature Importance (Interpretability)
# ==========================================
importances = pd.DataFrame({
    'feature': features.columns,
    'importance': rf_model.feature_importances_
}).sort_values('importance', ascending=False)

print("\nTop Predictive Features:")
print(importances.head(5))

# ==========================================
# 6. Export Predictions (Simulate DB Write)
# ==========================================
# In production:
# predictions_df.to_sql('song_popularity_predictions', mysql_conn, if_exists='append')
print("\n[System] Predictions generated and ready for database insert.")