# ✅ 2 to 10 App – Phase 1 Development Task List

> Version: Phase 1 (Local Play Only)  
> Last Updated: [YYYY-MM-DD]  
> Budget: $500  
> Timeline: ~8 Days  
> Status Legend:  
> - [ ] = Not Started  
> - [/] = In Progress  
> - [x] = Completed  

---

## �� Project Setup

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

- [x] Build `PlayerBox` widget (shows name, bid, score, bags, strikeout)  
- [x] Implement game screen layout: 4 players in N/S/E/W layout  
- [x] Add felt green background  
- [x] Center panel with round info, power suit, and input area  
- [x] Build `BidInputWidget` for bid entry  
- [ ] Build `TrickWinnerSelector` widget for each trick (not needed, as trick resolution is automatic)  
- [x] Add start round / next trick / end round button logic  
- [x] Build summary screen with final scores (basic, confetti not yet added)  

---

## 🕹 Game Logic Implementation

- [x] Implement round flow: Round 2 → Round 10  
- [x] Add random power suit generator per round  
- [x] Add bidding input and validation  
- [x] Add trick tracking per round  
- [x] Add manual winner selection for each trick (not needed, handled automatically)  
- [x] Track number of tricks per player

---

## 🧮 Scoring System

- [x] Calculate round score based on:
  - exact match = +10 × bid
  - overbid = +10 × bid +1 per bag
  - underbid = –10 × bid
  - 0 bid logic
- [x] Track and apply bags per player  
- [x] Apply –50 penalty for every 5 bags  
- [x] Track and evaluate Perfect and Immaculate games  
- [x] Apply tiebreaker rule on game end  

---

## 🎉 Confetti & Summary

- [ ] Add confetti effect to `SummaryScreen`  
- [x] Determine winner (apply tiebreaker if needed)  
- [x] Display each player's stats (score, bags, bonuses)  

---

## 🧪 Testing & Polish

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

---

## 📌 Final Checklist Before Delivery

- [ ] ✅ All tasks above marked complete  
- [ ] ✅ App runs on both Android & iOS  
- [ ] ✅ Summary screen shows accurate results  
- [ ] ✅ No crashes or blocking bugs  
- [ ] ✅ Code is organized and ready for Phase 2 upgrade

---

