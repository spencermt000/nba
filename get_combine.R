library(hoopR)
library(tidyverse)

# Define the range of seasons
seasons <- 2012:2024

# Initialize an empty list to store results
all_draft_stats <- list()

# Loop through each season
for (season in seasons) {
  # Try to retrieve draft combine stats for each season
  draft_stats <- tryCatch(
    nba_draftcombinestats(
      league_id = "00",
      season_year = season
    ),
    error = function(e) {
      cat(sprintf("Error retrieving draft combine stats for season %d: %s\n", season, e$message))
      return(NULL)  # Return NULL on error
    }
  )
  
  # Check if data retrieval was successful
  if (is.null(draft_stats)) {
    print(sprintf("ERROR: Skipping season %d.", season))
    next  # Skip to the next season if there was an error
  }
  
  # Store the DraftCombineStats data
  all_draft_stats[[as.character(season)]] <- draft_stats$DraftCombineStats
  
  # Print success message
  cat(sprintf("Successfully retrieved draft combine stats for season %d\n", season))
  
  # Pause for half a second
  Sys.sleep(0.5)
}

# Combine all draft stats into a single dataframe (if desired)
combined_df <- bind_rows(all_draft_stats, .id = "season")

# Optionally, write the combined data to a CSV file
# write_csv(combined_df, "combined_draft_combine_stats.csv")

cat("Data retrieval complete.\n")