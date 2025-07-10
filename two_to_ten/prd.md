# Product Requirements Document (PRD)

## Product Title
**2 to 10 – Local Card Game App (Phase 1 MVP)**

---

## Overview

"2 to 10" is a 4-player, free-for-all, trick-taking card game inspired by Spades but with custom rules and a rotating dominant suit each round. This Phase 1 release is a **local-play-only version** built for a **single device** using Flutter. The app will allow players to input bids, play out tricks with automatic evaluation, calculate scores, and display a game summary at the end of Round 10.

---

## Goals

- Implement core game logic (bidding, trick tracking, power suit, scoring).
- Design a clean, minimal, single-device UI for pass-and-play.
- Support rounds 2–10, with accurate scorekeeping and bag management.
- Include full card visuals for trick resolution (not just text input).
- Build with modularity for easy extension in future phases (online play, AI, etc.).
- Stay within a $500 scope and ~8 day timeline.

---

## Features

### 🕹 Gameplay Rules
- 4 Players always (no more, no less).
- 9 Rounds total: Round 2 to Round 10.
- Round N = N cards dealt per player = N tricks in that round.
- Cards are **randomly reshuffled and re-dealt** every round.
- Each round has a randomly selected **power suit** (♠, ♥, ♦, ♣).
- Players must follow the lead suit if able.
- Power suit beats all others. Among power suits, higher card wins.
- A trick is a set of 4 played cards. Highest wins the trick.

### 🎯 Bidding
- Each player bids how many tricks they think they'll win for the round.
- Bidding input UI before each round starts.
- Bids are from 0 up to round number (e.g., 0–5 for Round 5).

### 🃏 Card Visuals
- Each player is dealt a visible hand of cards.
- Card visuals include suit and rank (e.g., "♠A", "♥10").
- Hands are displayed on-screen at the start of the round.
- Trick plays are shown with animations or flipping visuals (basic).
- **Testing Mode**: All players' cards are visible during bidding phase for development/testing.
- **Production Mode**: Cards are face down during bidding phase (normal gameplay).

### 🤖 Trick Tracking
- Trick resolution is **automatic**:
  - Player plays a card from their hand.
  - System compares all 4 played cards.
  - Determines and records winner based on rules (lead suit vs. power suit).
- Trick history is stored temporarily for scoring and review.

### 🧾 Scoring Rules
- If bid is matched exactly: +10 points per trick.
- If underbid (got set): –10 × bid.
- If overbid: +10 × bid +1 per extra trick (bag).
- Every 5 bags = –50 points (bag out penalty).
- Bids of 0:
  - If win 0 tricks: ✅ **+0 points**
  - If win any tricks: +1 point per trick (bags only).

### 🏆 Bonuses
- **Perfect Game**: hit exact bid all 9 rounds = +50 points.
- **Immaculate Game**: bid 0 and win 0 in all rounds = +100 points.

### 🤝 Tiebreaker Rule
If players are tied after Round 10, the winner is the player with the most rounds **not set** (i.e., hit or overbid).

---

## UI/UX Design

### Design Targets
- 🎨 **Full card visuals** (suit + rank) displayed in player's hands.
- 🟩 **Green felt background**, simple grid layout.
- 🧍 **Players**: Default to Player 1–4 for names.
- 🖼️ Layout optimized for **mobile phones only**.

### Screens

#### Screen 1: Game Screen
- 4 Player Boxes (top, bottom, left, right) with:
  - Name
  - Bid
  - Score
  - Bag count (⚠️ when 4+)
  - Strike-through name if perfect streak is broken.
- Center area:
  - Round number
  - Power suit display
  - Card play area
  - Button to start round, next trick, end round

#### Screen 2: Summary Screen
- Show final scores
- Highlight winner
- Confetti effect on win
- Show Perfect/Immaculate if achieved

---

## Technical

### Platform
- Flutter (iOS & Android)
- State Management: Provider
- Confetti: [`confetti` package](https://pub.dev/packages/confetti)

### Code Architecture
- MVC or Clean Architecture
- Core Models:
  - `Player`
  - `Round`
  - `GameState`

### Data Flow
- Round starts → cards dealt → bids entered → tricks played → scoring → next round
- Cards are removed from hand after play
- Score and bags are tracked persistently

---

## Development & Testing Features

### 🧪 Testing Mode
- **Card Visibility Control**: Toggle to show/hide all players' cards during bidding phase
- **Development Mode**: All cards visible for testing trick logic and AI decisions
- **Production Mode**: Cards face down during bidding (normal gameplay)
- **Easy Toggle**: Single constant controls the entire testing mode

### 🔧 Configuration
- Testing mode controlled by `showAllCardsDuringBidding` constant in `GameConstants`
- Set to `true` for development/testing
- Set to `false` for production release

---

## Timeline Estimate

| Task                           | Time      |
|--------------------------------|-----------|
| Project Setup                  | 0.5 day   |
| Game Models & State            | 1.5 days  |
| UI Implementation              | 2 days    |
| Game Flow Logic                | 2 days    |
| Score & Bonus Calculations     | 1 day     |
| Testing & Debugging            | 1 day     |
| Confetti Integration & Polish  | 0.5 day   |
| **Total**                      | **~8 days**|

---

## Excluded From This Phase
- Online multiplayer
- AI bots
- Game history
- Login/account system
- Sound effects
- Tablet optimization
- Custom player names
- In-app rule/tutorial screen

---
