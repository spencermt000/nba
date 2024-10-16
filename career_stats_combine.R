library(hoopR)
library(tidyverse)
options(scipen=999)

# Read player data and select relevant columns
players <- read_csv("combine_stats_2003_2024.csv")
players <- players %>% select(PLAYER_ID, PLAYER_NAME)

# Get unique player IDs
ids <- unique(players$PLAYER_ID)

# Initialize master dataframes
master_season <- data.frame()
master_college <- data.frame()

# Loop through each player ID
for (i in seq_along(ids)) {
  player_id <- ids[i]
  
  # Progress report
  print(paste("Processing player", i, "of", length(ids), "- PLAYER_ID:", player_id))
  
  # Try to fetch player career stats
  tryCatch({
    test <- nba_playercareerstats(player_id = player_id)
    
    # Extract season and college data
    season <- test$SeasonTotalsRegularSeason
    college <- test$SeasonTotalsCollegeSeason
    
    # Bind the data to the master dataframes
    if (nrow(season) > 0) {
      master_season <- bind_rows(master_season, season)
    }
    if (nrow(college) > 0) {
      master_college <- bind_rows(master_college, college)
    }
    
    # Short delay
    Sys.sleep(0.05)
    
  }, error = function(e) {
    # Skip player if there's an error and print the error message
    print(paste("Error for PLAYER_ID:", player_id, "-", e$message))
  })
  
  # Progress report
  print(paste("Completed player", i, "of", length(ids)))
}

# Print final report
print("Data collection complete.")