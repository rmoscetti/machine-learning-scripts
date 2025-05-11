# Matchbox Tic-Tac-Toe AI (Teaching Demo)

A teaching script implementing a Tic-Tac-Toe AI based on the classic Matchbox Reinforcement Learning algorithm (MENACE). Each matchbox represents a board state and contains beads indicating the probabilities of selecting each move. Over simulated games, the AI learns by adding or removing beads based on outcomes.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Script Structure](#script-structure)
7. [Reference Study](#reference-study)
8. [Author & License](#author--license)

---

## Overview

This R script (`matchbox_tictactoe_teach.R`) demonstrates a pedagogical implementation of the Matchbox Reinforcement Learning algorithm for the game of Tic-Tac-Toe. It is intended for teaching purposes, illustrating:

* How to represent game states with simple data structures.
* How to initialize and update probabilistic move selections (beads in matchboxes).
* How reinforcement through wins, losses, and draws shapes AI behavior over many simulated matches.

---

## Features

* **State Representation**: Board states as 9-character strings.
* **Matchbox Initialization**: Even distribution of beads among empty positions.
* **Reinforcement Update**: Reward or penalize moves by adjusting bead counts after each game.
* **Simulation Loop**: Simulates batches of games, tracking win/lose/draw rates.
* **Visualization**: Plots learning curves (win/lose/draw rates over batches) and example bead distributions.

---

## Prerequisites

* R (version ≥ 4.0)
* No external R packages required (base R functions only).

---

## Installation

1. Clone or download this repository:

   ```bash
   git clone https://github.com/rmoscetti/machine-learning-scripts.git
   ```
2. Navigate to the project directory:

   ```bash
   cd matchbox-tictactoe-ai
   ```
3. Open the script in R or RStudio:

   ```bash
   Rscript matchbox_tictactoe_teach.R
   ```

---

## Usage

1. Run the script to start simulations:

   ```r
   source("matchbox_tictactoe_teach.R")
   ```
2. View console output to monitor progress of win/lose/draw rates.
3. Observe generated plot showing the AI's learning curve.
4. Optionally, use the `board_status()` function to print the board at any given state for debugging or demonstration.

---

## Script Structure

* **Header**: Author, version, date, description, teaching note, reference.
* **Functions**:

  * `XO_positions()`: Extract X and O positions.
  * `board_status()`: Print formatted board.
  * `win_loss_check()`: Determine game outcome.
  * `update_state()`: Apply a move to the board state.
  * `matchbox_create_prob()`: Initialize matchbox bead probabilities.
  * `matchbox_update_prob()`: Update bead counts post-game.
  * `random_player()`: Simulate human moves.
  * `AI_player()`: Select moves based on bead probabilities.
  * `AI_history()`: Record AI moves for reinforcement.
  * `game()`: Run a full game and update matchboxes.
* **Main Simulation**: Loop over batches to simulate learning.
* **Visualization**: Plot rates and bead histograms.

---

## Reference Study

Inspired by the **Matchbox Educable Noughts and Crosses Engine (MENACE)**:

* Wikipedia: [https://en.wikipedia.org/wiki/Matchbox\_Educable\_Noughts\_and\_Crosses\_Engine](https://en.wikipedia.org/wiki/Matchbox_Educable_Noughts_and_Crosses_Engine)

---

## Author & License

* **Author**: Roberto Moscetti
* **Version**: v1.0.0
* **Date**: 2025-05-11
* **License**: MIT © 2025 Roberto Moscetti
