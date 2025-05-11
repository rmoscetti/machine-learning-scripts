# ==============================================================================
# Author: Roberto Moscetti
# Version: v1.0.0
# Date: 2025-05-11
# Description:
#     Tic-Tac-Toe AI using the Matchbox Reinforcement Learning algorithm
#     Each matchbox represents a board state; beads represent possible
#     moves and their probabilities
#     Script for teaching purposes
# References:
#     Matchbox Educable Noughts and Crosses Engine:
#     https://en.wikipedia.org/wiki/Matchbox_Educable_Noughts_and_Crosses_Engine
# ==============================================================================

# Function: XO_positions
# Description: Given a board state string, returns the indices of X and O positions.
# Input: state - a single string of length 9, each character "X", "O", or " " (space) representing the board.
# Output: A named list with elements $X and $O containing vectors of occupied positions.
XO_positions <- function(state){
  # Split state string into characters
  cells <- strsplit(state, "")[[1]]
  # Find positions of X and O
  X_positions <- which(cells == "X")
  O_positions <- which(cells == "O")
  
  # Package into named list
  positions <- list(X_positions, O_positions)
  names(positions) <- c("X", "O")
  return(positions)
}

# Function: board_status (optional)
# Description: Prints a human-readable 3x3 board, marking X and O in their positions.
# Input: state - same as XO_positions
board_status <- function(state){
  positions <- XO_positions(state)
  
  # Template for empty board with cell numbers as placeholders
  board <- "-------------\n  | 1 | 2 | 3 |\n  -------------\n  | 4 | 5 | 6 |\n  -------------\n  | 7 | 8 | 9 |\n  -------------\n"
  
  # Replace placeholders with X
  for (pos in positions$X) {
    board <- gsub(as.character(pos), "X", board)
  }
  # Replace placeholders with O
  for (pos in positions$O) {
    board <- gsub(as.character(pos), "O", board)
  }
  
  # Print the board
  cat(board)
}

# Function: win_loss_check
# Description: Checks current state for a win, loss, draw, or ongoing game.
# Return values:
#  - "win": AI (O) has three in a row
#  - "lose": human (X) has three in a row
#  - "draw": board full without three in a row
#  - 0: game still ongoing
win_loss_check <- function(state){
  # All possible winning combinations
  win_conditions <- list(
    c(1,2,3), c(4,5,6), c(7,8,9),     # rows
    c(1,4,7), c(2,5,8), c(3,6,9),     # columns
    c(1,5,9), c(3,5,7)                # diagonals
  )
  
  positions <- XO_positions(state)
  
  # Check each win condition for X or O
  for (cond in win_conditions) {
    if (all(cond %in% positions$X)) {
      return("lose")  # human wins => AI loses
    } else if (all(cond %in% positions$O)) {
      return("win")   # AI wins
    }
  }
  
  # If no spaces remain, it's a draw
  if (all(strsplit(state, "")[[1]] != " ")) {
    return("draw")
  }
  
  # Otherwise, game is still in progress
  return(0)
}

# Function: update_state
# Description: Places a symbol at a given position in the state string and returns updated state.
# Inputs:
#  - state: current board string
#  - position: integer 1-9 where to place
#  - symbol: "X" or "O"
# Output: new state string
update_state <- function(state, position, symbol){
  cells <- strsplit(state, "")[[1]]
  cells[position] <- symbol
  return(paste(cells, collapse = ""))
}

# Function: matchbox_create_prob
# Description: Initializes a matchbox for a state if not present, distributing beads evenly.
# Uses global 'matchboxes' list. Each matchbox is a numeric vector of length 9.
matchbox_create_prob <- function(state){
  # Only initialize if state not already seen
  if (!(state %in% names(matchboxes))) {
    empty_positions <- which(strsplit(state, "")[[1]] == " ")
    initial_prob <- 1 / length(empty_positions)
    # Create vector of zeros and assign equal probability to empty cells
    matchboxes[[state]] <<- rep(0, 9)
    matchboxes[[state]][empty_positions] <<- initial_prob
  }
}

# Function: matchbox_update_prob
# Description: After game ends, adjust bead counts based on result and AI moves.
# Inputs:
#  - AI_moves: named list mapping state -> chosen move
#  - result: "win", "lose", or "draw"
matchbox_update_prob <- function(AI_moves, result){
  for (state in names(AI_moves)) {
    move <- AI_moves[[state]]
    if (result == "win") {
      # Reward winning moves slightly
      matchboxes[[state]][move] <<- matchboxes[[state]][move] + 0.03
    } else if (result == "lose") {
      # Penalize losing moves
      matchboxes[[state]][move] <<- max(0, matchboxes[[state]][move] - 0.01)
    } else if (result == "draw") {
      # Small reward for draws
      matchboxes[[state]][move] <<- matchboxes[[state]][move] + 0.01
    }
    # Normalize to maintain probability distribution
    matchboxes[[state]] <<- matchboxes[[state]] / sum(matchboxes[[state]])
  }
}

# Function: random_player
# Description: Simulates human move by choosing a random empty cell.
random_player <- function(state){
  empty_positions <- which(strsplit(state, "")[[1]] == " ")
  return(sample(empty_positions, 1))
}

# Function: AI_player
# Description: Chooses a move based on bead probabilities in the matchbox for current state.
AI_player <- function(state){
  # Ensure matchbox exists
  matchbox_create_prob(state)
  probs <- matchboxes[[state]]
  # Sample one of 1:9 positions weighted by beads
  selection <- sample(1:9, 1, prob = probs)
  return(selection)
}

# Function: AI_history
# Description: Records the AI's chosen move for a state in AI_moves list.
AI_history <- function(state, AI_move, AI_moves){
  AI_moves[[state]] <- AI_move
  return(AI_moves)
}

# Function: game
# Description: Runs one complete game between AI and random player, updates matchboxes.
# Returns: result string ("win", "lose", or "draw").
game <- function(){
  AI_moves <- list()
  state <- paste(rep(" ", 9), collapse = "")
  matchbox_create_prob(state)
  
  # Randomly choose who starts: FALSE=AI, TRUE=human
  # c(FALSE, FALSE) forces the AI to always start the game
  if (sample(c(FALSE, FALSE), 1)) {
    # Human starts
    move <- random_player(state)
    state <- update_state(state, move, "X")
    turn <- "AI"
  } else {
    # AI starts
    move <- AI_player(state)
    AI_moves <- AI_history(state, move, AI_moves)
    state <- update_state(state, move, "O")
    turn <- "human"
  }
  matchbox_create_prob(state)
  
  # Play until end
  while (win_loss_check(state) == 0) {
    if (turn == "human") {
      move <- random_player(state)
      state <- update_state(state, move, "X")
      turn <- "AI"
    } else {
      move <- AI_player(state)
      AI_moves <- AI_history(state, move, AI_moves)
      state <- update_state(state, move, "O")
      turn <- "human"
    }
    matchbox_create_prob(state)
  }
  
  # Determine outcome and update beads
  result <- win_loss_check(state)
  matchbox_update_prob(AI_moves, result)
  return(result)
}

# Initialization: empty list of matchboxes and vectors for stats
matchboxes <- list()
win_rate <- lose_rate <- draw_rate <- numeric(50)

# Simulate 20 batches of 1000 games, track evolving win/lose/draw rates
for (j in 1:20) {
  wins <- losses <- draws <- 0
  for (i in 1:1000) {
    outcome <- game()
    if (outcome == "win")    wins <- wins + 1
    if (outcome == "lose")   losses <- losses + 1
    if (outcome == "draw")   draws <- draws + 1
    
    win_rate[j]  <- round(wins/i,  3)
    lose_rate[j] <- round(losses/i, 3)
    draw_rate[j] <- round(draws/i, 3)
    
    # Progress output (overwritten each iteration)
    cat(sprintf("%3d - W:%.3f L:%.3f D:%.3f\r", j, win_rate[j], lose_rate[j], draw_rate[j]) )
  }
  # Final summary for batch
  cat(sprintf("%3d - W:%.3f L:%.3f D:%.3f\n", j, win_rate[j], lose_rate[j], draw_rate[j]))
}

# Plotting results: win (green), lose (red), draw (blue)
plot(0, 0, xlim = c(1,50), ylim = c(0,1), xlab = "Batch", ylab = "Rate", type = "n")
lines(win_rate, col = "green")
lines(lose_rate, col = "red")
lines(draw_rate, col = "blue")

# Example: barplot of beads in the first initialized matchbox
barplot(matchboxes[[1]], main = "Bead distribution at initial state")
