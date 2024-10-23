library(tidyverse)
library(hoopR)

sched <- espn_nba_scoreboard(2024)
sched2 <- espn_nba_scoreboard(2023)
sched3 <- espn_nba_scoreboard(2022)

# Filter for regular season (type 2) and playoff games (type 3) with play-by-play data available
sched <- sched %>% filter(season_type == 2 | season_type == 3) %>% filter(play_by_play_available == T)
sched2 <- sched2 %>% filter(season_type == 2 | season_type == 3) %>% filter(play_by_play_available == T)
sched3 <- sched3 %>% filter(season_type == 2 | season_type == 3) %>% filter(play_by_play_available == T)

# Combine the schedules
sched <- bind_rows(sched, sched2, sched3)

# Get all game_ids
game_ids <- sched$game_id

# Initialize empty data frame to store results and vector for bad ids
master <- data.frame()
bad_ids <- c()

# Loop through game_ids
for (looping_id in game_ids) {
  print(paste("Processing game_id:", looping_id))
  
  # Try block
  tryCatch({
    # Fetch player box score for the game_id
    test <- espn_nba_player_box(looping_id)
    
    # Rename and select necessary columns
    test <- test %>%
      rename(fga = field_goals_attempted, 
             fgm = field_goals_made,
             tpa = three_point_field_goals_attempted,
             tpm = three_point_field_goals_made,
             fta = free_throws_attempted,
             ftm = free_throws_made, 
             oreb = offensive_rebounds,
             dreb = defensive_rebounds, 
             reb = rebounds,
             ast = assists,
             stl = steals,
             blk = blocks, 
             to = turnovers, 
             pf = fouls,
             pts = points, 
             plus_minus = plus_minus) %>%
      select(game_id, season, season_type, game_date, team_id, team_short_display_name, team_logo,
             athlete_id, athlete_display_name, athlete_position_abbreviation, athlete_headshot_href,
             fga, fgm, tpa, tpm, fta, ftm, oreb, dreb, reb, ast, stl, blk, to, pf, pts, plus_minus,
             team_score, team_winner, opponent_team_id, opponent_team_score)
    
    # Append to master data frame
    master <- bind_rows(master, test)
    
    print(paste("Successfully processed game_id:", looping_id))
    
  }, error = function(e) {
    # If an error occurs, add to bad_ids and print the error message
    bad_ids <<- c(bad_ids, looping_id)
    print(paste("Error with game_id:", looping_id, "- skipping."))
  })
}

# Final progress
print("Processing complete.")
print(paste("Bad game_ids:", paste(bad_ids, collapse = ", ")))