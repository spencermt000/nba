library(hoopR)
library(tidyverse)

##### sched
sched1 <- nba_schedule(league_id = "00", season = 2024)
sched2 <- nba_schedule(league_id = "00", season = 2023)
sched3 <- nba_schedule(league_id = "00", season = 2022)
sched4 <- nba_schedule(league_id = "00", season = 2021)
sched5 <- nba_schedule(league_id = "00", season = 2020)
sched6 <- nba_schedule(league_id = "00", season = 2019)
sched7 <- nba_schedule(league_id = "00", season = 2018)
sched8 <- nba_schedule(league_id = "00", season = 2017)
sched9 <- nba_schedule(league_id = "00", season = 2016)
sched10 <- nba_schedule(league_id = "00", season = 2015)

sched <- bind_rows(sched1, sched2, sched3, sched4, sched5, sched6, sched7, sched8, sched9, sched10)

game_ids <- sched$game_id

# Initialize master data frames
master_adv <- data.frame() # Empty data frame for advanced stats
master_mat <- data.frame()  # Empty data frame for matchups
master_def <- data.frame()  # Empty data frame for defensive stats
master_hustle <- data.frame()  # Empty data frame for hustle stats
master_trc <- data.frame()  # Empty data frame for player tracking stats

# Loop through each game ID
total_games <- length(game_ids)
for (i in seq_along(game_ids)) {
  looping_id <- game_ids[i]
  
  df <- tryCatch(
    nba_boxscoreadvancedv3(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving advanced stats for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  df2 <- tryCatch(
    nba_boxscorematchupsv3(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving matchups for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  df3 <- tryCatch(
    nba_boxscoredefensivev2(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving defensive stats for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  df4 <- tryCatch(
    nba_hustlestatsboxscore(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving hustle stats for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  df5 <- tryCatch(
    nba_boxscoreplayertrackv3(game_id = looping_id),
    error = function(e) {
      cat(sprintf("Error retrieving player tracking stats for Game ID %s: %s\n", looping_id, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  # Check if data retrieval was successful
  if (is.null(df) || is.null(df2) || is.null(df3) || is.null(df4) || is.null(df5)) {
    cat("ERROR: Skipping Game ID", looping_id, "\n")
    next  # Skip to the next game_id if there was an error
  }
  
  # Combine home and away data
  home_adv <- df$home_team_player_advanced
  away_adv <- df$away_team_player_advanced
  adv <- bind_rows(home_adv, away_adv)
  
  home_mat <- df2$home_team_player_matchups
  away_mat <- df2$away_team_player_matchups
  mat <- bind_rows(home_mat, away_mat)
  
  home_def <- df3$home_team_player_defensive
  away_def <- df3$away_team_player_defensive
  def <- bind_rows(home_def, away_def)
  
  hustle_stats <- df4$PlayerStats
  hustle <- bind_rows(hustle_stats)
  
  home_trc <- df5$home_team_player_player_track
  away_trc <- df5$away_team_player_player_track
  trc <- bind_rows(home_trc, away_trc)
  
  # Append to master data frames
  master_adv <- bind_rows(master_adv, adv)
  master_mat <- bind_rows(master_mat, mat)
  master_def <- bind_rows(master_def, def)
  master_hustle <- bind_rows(master_hustle, hustle)
  master_trc <- bind_rows(master_trc, trc)
  
  # Print progress update
  cat(sprintf("Processed game %d of %d: Game ID %s\n", i, total_games, looping_id))
  
  # Pause for half a second
  Sys.sleep(0.5)
}

cat("Data processing complete. CSV files have been written.\n")