# Test Cases for 2 to 10 Game

This document records all test cases covered by the current test suite. For each case, we explain:
1. **What is tested**
2. **Expected result**
3. **Actual result**

---

## Unit Tests (`test/unit/game_logic_test.dart`)

### Card Model
- **Card creation and display**
  - *Test*: Create a card and check its suit, rank, display string, and color.
  - *Expected*: Card properties match input; display string and color are correct.
  - *Actual*: ✅ Pass
- **Card value comparison**
  - *Test*: Compare values of Ace, King, Queen of Spades.
  - *Expected*: Ace > King > Queen.
  - *Actual*: ✅ Pass
- **All suits have correct colors**
  - *Test*: Check color mapping for all suits.
  - *Expected*: Each suit has correct color.
  - *Actual*: ✅ Pass

### Player Model
- **Player creation with default values**
  - *Test*: Create a player and check default fields.
  - *Expected*: score=0, bags=0, currentBid=0, tricksWon=0, correct round arrays.
  - *Actual*: ✅ Pass
- **Player bag warning**
  - *Test*: Check bag warning at 4 bags.
  - *Expected*: Warning at 4+ bags.
  - *Actual*: ✅ Pass
- **Player copyWith method**
  - *Test*: Copy player with new values.
  - *Expected*: All fields updated as specified.
  - *Actual*: ✅ Pass

### Round Model
- **Round creation with default values**
  - *Test*: Create a round and check fields.
  - *Expected*: Correct round number, power suit, hands, bids, etc.
  - *Actual*: ✅ Pass
- **Bid placement and tracking**
  - *Test*: Place bids for all players.
  - *Expected*: Bids are tracked and allBidsPlaced is true.
  - *Actual*: ✅ Pass
- **Trick completion and winner determination**
  - *Test*: Play a trick and determine winner.
  - *Expected*: Winner is correct based on rules.
  - *Actual*: ✅ Pass
- **Power suit beats all other suits**
  - *Test*: Power suit card wins over lead suit.
  - *Expected*: Power suit wins even if lower value.
  - *Actual*: ✅ Pass
- **Power suit vs power suit comparison**
  - *Test*: Higher power suit card wins.
  - *Expected*: Highest value of power suit wins.
  - *Actual*: ✅ Pass

### Game State
- **Game initialization**
  - *Test*: Check initial state of game and players.
  - *Expected*: 4 players, correct defaults.
  - *Actual*: ✅ Pass
- **Start new game**
  - *Test*: Start a new game and check round/hands.
  - *Expected*: Game started, round and hands initialized.
  - *Actual*: ✅ Pass
- **Bid placement**
  - *Test*: Place bids for all players.
  - *Expected*: Player bids are set and tracked.
  - *Actual*: ✅ Pass
- **Card playing and trick completion**
  - *Test*: Play cards for a trick and check trick winner.
  - *Expected*: Trick winner is correct, trick count updates.
  - *Actual*: ✅ Pass

### Scoring System
- **Exact bid scoring logic**
  - *Test*: Calculate score for exact bid.
  - *Expected*: +10 per trick bid.
  - *Actual*: ✅ Pass
- **Overbid scoring logic**
  - *Test*: Calculate score and bags for overbid.
  - *Expected*: +10 per bid +1 per extra trick (bag).
  - *Actual*: ✅ Pass
- **Underbid scoring logic**
  - *Test*: Calculate score for underbid.
  - *Expected*: -10 per bid.
  - *Actual*: ✅ Pass
- **Zero bid scoring - perfect**
  - *Test*: 0 bid, 0 tricks.
  - *Expected*: +0 points.
  - *Actual*: ✅ Pass
- **Zero bid scoring - bags only**
  - *Test*: 0 bid, >0 tricks.
  - *Expected*: +1 per trick (bags only).
  - *Actual*: ✅ Pass
- **Bag penalty system logic**
  - *Test*: Bags >= 5 triggers penalty.
  - *Expected*: -50 per 5 bags, bags reset.
  - *Actual*: ✅ Pass
- **Testing mode constant for card visibility**
  - *Test*: Testing mode controls card visibility during bidding.
  - *Expected*: Cards visible during bidding when testing mode is enabled.
  - *Actual*: ✅ Pass

### Edge Cases
- **Tiebreaker rule - most rounds not set**
  - *Test*: Tie on score, check tiebreaker.
  - *Expected*: Player with most rounds not set wins (or first in list if tied).
  - *Actual*: ✅ Pass
- **Multiple bag penalties logic**
  - *Test*: 10 bags triggers 2 penalties.
  - *Expected*: -100 points, bags reset.
  - *Actual*: ✅ Pass
- **Round progression from 2 to 10**
  - *Test*: Game progresses through all rounds.
  - *Expected*: Game completes after round 10.
  - *Actual*: ✅ Pass
- **All players bid 0 logic**
  - *Test*: All players bid 0, win 0 tricks.
  - *Expected*: +10 points each.
  - *Actual*: ✅ Pass
- **All players overbid logic**
  - *Test*: All players overbid by 1.
  - *Expected*: +11 points, 1 bag each.
  - *Actual*: ✅ Pass
- **All players underbid logic**
  - *Test*: All players underbid.
  - *Expected*: -20 points each.
  - *Actual*: ✅ Pass

---

## Integration Tests (`test/integration/game_flow_test.dart`)

- **Complete game with normal scoring**
  - *Test*: Simulate a full game with normal bids and trick play.
  - *Expected*: Game completes, scores are calculated, winner is determined.
  - *Actual*: ✅ Pass
- **Game with zero bids edge case**
  - *Test*: All players bid 0 in a round.
  - *Expected*: All bids accepted, tracked correctly.
  - *Actual*: ✅ Pass
- **Game with bag overflow edge case**
  - *Test*: Player starts with 4 bags, overbids to trigger warning.
  - *Expected*: Bag warning shown, bags tracked.
  - *Actual*: ✅ Pass
- **Game with tie scenario**
  - *Test*: Two players tie on score, tiebreaker applied.
  - *Expected*: Winner determined by tiebreaker logic.
  - *Actual*: ✅ Pass
- **Game with maximum overbid scenario**
  - *Test*: All players overbid in a round.
  - *Expected*: Bids tracked, bags incremented.
  - *Actual*: ✅ Pass
- **Game with maximum underbid scenario**
  - *Test*: All players underbid in a round.
  - *Expected*: Bids tracked, negative scores possible.
  - *Actual*: ✅ Pass
- **Game with mixed scoring scenarios**
  - *Test*: Mix of exact, over, under, and zero bids.
  - *Expected*: Bids tracked, scoring logic applies.
  - *Actual*: ✅ Pass
- **Game state persistence through rounds**
  - *Test*: Play through several rounds, check state.
  - *Expected*: State persists, scores accumulate.
  - *Actual*: ✅ Pass
- **Power suit changes each round**
  - *Test*: Power suit is randomized each round.
  - *Expected*: Power suit is valid and changes.
  - *Actual*: ✅ Pass

---

## Widget/UI Tests (`test/widget/ui_components_test.dart`)

- **PlayerBox displays player information**
  - *Test*: Renders player name, score, bid, bags.
  - *Expected*: All info visible.
  - *Actual*: ✅ Pass
- **PlayerBox shows bag warning**
  - *Test*: Bag warning icon at 4+ bags.
  - *Expected*: Warning icon visible.
  - *Actual*: ✅ Pass
- **PlayerBox shows turn indicator**
  - *Test*: Turn indicator when it's player's turn.
  - *Expected*: Indicator visible.
  - *Actual*: ✅ Pass
- **BidInputWidget shows dialog for bidding**
  - *Test*: Dialog appears for bidding.
  - *Expected*: Dialog and bid range visible.
  - *Actual*: ✅ Pass
- **BidInputWidget allows bid selection**
  - *Test*: User can select bid value.
  - *Expected*: Bid value changes.
  - *Actual*: ✅ Pass
- **GameScreen shows start game button**
  - *Test*: Start button visible initially.
  - *Expected*: Button visible.
  - *Actual*: ✅ Pass
- **GameScreen starts game**
  - *Test*: Start button starts game.
  - *Expected*: Game state updates, round visible.
  - *Actual*: ✅ Pass
- **GameScreen shows all 4 player boxes**
  - *Test*: All player names visible.
  - *Expected*: 4 names visible.
  - *Actual*: ✅ Pass
- **GameScreen shows power suit indicator**
  - *Test*: Power suit displayed.
  - *Expected*: Power suit visible.
  - *Actual*: ✅ Pass
- **GameScreen handles 10-card round overflow**
  - *Test*: UI does not overflow with 10 cards.
  - *Expected*: Scrollable areas present.
  - *Actual*: ✅ Pass
- **BidInputWidget handles zero bid correctly**
  - *Test*: 0 is a valid bid option.
  - *Expected*: 0 can be selected, no crash.
  - *Actual*: ✅ Pass

---

**Legend:**
- ✅ Pass = Test passes, actual result matches expected
- ❌ Fail = Test fails, actual result does not match expected 