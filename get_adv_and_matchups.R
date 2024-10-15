library(hoopR)
library(tidyverse)

# Get the NBA schedule for the specified season
season <- 2023
sched <- nba_schedule(league_id = "00", season = season)

# Filter the schedule for regular-season games
sched <- sched %>%
  filter(season_type_id == 2) %>%
  select(game_id, game_date, home_team_id, away_team_id, home_team_score, away_team_score)

# Extract game IDs
game_ids <- sched$game_id

# Initialize master data frames
master_adv <- data.frame() # Empty data frame for advanced stats
master_mat <- data.frame()  # Empty data frame for matchups

# Loop through each game ID
total_games <- length(game_ids)
for (i in seq_along(game_ids)) {
  looping_id <- game_ids[i]
  
  # Try to retrieve boxscore advanced data
  df <- tryCatch(
    nba_boxscoreadvancedv3(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving advanced stats for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  # Try to retrieve boxscore matchups data
  df2 <- tryCatch(
    nba_boxscorematchupsv3(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving matchups for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  # Check if data retrieval was successful
  if (is.null(df) || is.null(df2)) {
    print("ERROR: Skipping Game ID")  # More descriptive error message
    next  # Skip to the next game_id if there was an error
  }
  
  # Bind advanced stats for home and away teams
  h_adv <- df$home_team_player_advanced
  a_adv <- df$away_team_player_advanced
  adv <- bind_rows(h_adv, a_adv)
  
  # Bind matchups for home and away teams
  h_mat <- df2$home_team_player_matchups
  a_mat <- df2$away_team_player_matchups
  mat <- bind_rows(h_mat, a_mat)
  
  # Append to master data frames
  master_adv <- bind_rows(master_adv, adv)
  master_mat <- bind_rows(master_mat, mat)
  
  # Print progress update
  cat(sprintf("Processed game %d of %d: Game ID %s\n", i, total_games, looping_id))
  
  # Pause for half a second
  Sys.sleep(0.5)
}

# Write master data frames to CSV files
write_csv(master_adv, paste0("master_adv_season_", season, ".csv"))
write_csv(master_mat, paste0("master_mat_season_", season, ".csv"))

cat("Data processing complete. CSV files have been written.\n")