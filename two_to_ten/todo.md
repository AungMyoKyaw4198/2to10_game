# ✅ 2 to 10 App – Phase 1 Development Task List

> Version: Phase 1 (Local Play Only)  
> Last Updated: 2024-12-19  
> Budget: $500  
> Timeline: ~8 Days  
> Status Legend:  
> - [ ] = Not Started  
> - [/] = In Progress  
> - [x] = Completed  

---

## 🚀 Project Setup

- [x] Initialize Flutter project and Git repo  
- [x] Add required dependencies (provider, confetti, google_fonts, shared_preferences)  
- [x] Set up base folder structure (lib/models, lib/screens, lib/widgets, lib/providers, lib/constants)  
- [x] Define constants and suit list (`['♠', '♥', '♦', '♣']`)

---

## 🧠 Core Game Models & State

- [x] Create `Player` model  
- [x] Create `Round` model  
- [x] Create `GameState` class with ChangeNotifier  
- [x] Implement provider state wiring in `main.dart`

---

## 🎨 UI & Layout

- [x] Build `PlayerBox` widget (shows name, bid, score, bags, perfect/immaculate streaks)  
- [x] Implement game screen layout: 4 players in N/S/E/W layout  
- [x] Add felt green background  
- [x] Center panel with round info, power suit, and input area  
- [x] Build `BidInputWidget` for bid entry (with dialog-based UI)  
- [x] Add start round / next trick / end round button logic  
- [x] Build summary screen with final scores (basic, confetti not yet added)  
- [x] Fix dialog state management and setState errors

---

## 🕹 Game Logic Implementation

- [x] Implement round flow: Round 2 → Round 10  
- [x] Add random power suit generator per round  
- [x] Add bidding input and validation  
- [x] Add trick tracking per round  
- [x] Add automatic trick resolution (power suit rules)  
- [x] Track number of tricks per player
- [x] Implement clockwise turn order for first trick
- [x] Update player positions (Player 3 left, Player 2 bottom)

---

## 🧮 Scoring System

- [x] Calculate round score based on:
  - exact match = +10 × bid
  - overbid = +10 × bid +1 per bag
  - underbid = –10 × bid
  - 0 bid logic (perfect 0 = +10, any tricks = bags only)
- [x] Track and apply bags per player  
- [x] Apply –50 penalty for every 5 bags  
- [x] Track and evaluate Perfect and Immaculate games  
- [x] Apply tiebreaker rule on game end (most rounds not set)  

---

## 🎉 Confetti & Summary

- [ ] Add confetti effect to `SummaryScreen`  
- [x] Determine winner (apply tiebreaker if needed)  
- [x] Display each player's stats (score, bags, bonuses)  

---

## 🧪 Testing & Polish

- [x] Fix BidInputWidget dialog closing issue
- [x] Fix setState called after dispose error
- [x] Implement proper widget lifecycle management
- [ ] Test all edge cases (0 bids, bag overflow, ties)  
- [/] Refactor code for clarity and modularity (partially done, ongoing)  
- [ ] Clean up unused code and assets  
- [ ] Prepare production build for APK  
- [ ] Deliver source code + instructions to client  

---

## 📝 Optional (Stretch / Future)

- [ ] Add custom player name input  
- [ ] Add score explanation pop-up  
- [ ] Add pause / reset game state button  
- [ ] Make layout responsive for tablets  
- [ ] Add sound effects for card playing
- [ ] Add animations for trick resolution

---

## 📌 Final Checklist Before Delivery

- [ ] ✅ All tasks above marked complete  
- [ ] ✅ App runs on both Android & iOS  
- [ ] ✅ Summary screen shows accurate results  
- [ ] ✅ No crashes or blocking bugs  
- [ ] ✅ Code is organized and ready for Phase 2 upgrade

---

## 🔧 Recent Fixes (2024-12-19)

- [x] Fixed BidInputWidget dialog not closing after last player bids
- [x] Fixed setState called after dispose error
- [x] Added proper mounted checks and lifecycle management
- [x] Swapped Player 2 and Player 3 positions for clockwise turn order
- [x] Updated player layout: Player 0 (top), Player 1 (right), Player 2 (bottom), Player 3 (left)
- [x] Verified bidding and playing order follows clockwise sequence

---

