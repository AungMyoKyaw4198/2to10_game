import 'card.dart';

class Round {
  final int roundNumber;
  final String powerSuit;
  final List<List<Card>> playerHands;
  final List<Card> currentTrick;
  final List<int> trickWinners;
  final List<int> bids;
  final int currentTrickIndex;
  final bool isComplete;
  final int dealer; // Track the dealer for this round

  Round({
    required this.roundNumber,
    required this.powerSuit,
    required this.playerHands,
    List<Card>? currentTrick,
    List<int>? trickWinners,
    List<int>? bids,
    this.currentTrickIndex = 0,
    this.isComplete = false,
    required this.dealer,
  }) : currentTrick = currentTrick ?? [],
       trickWinners = trickWinners ?? [],
       bids =
           bids ??
           List.filled(4, -1); // Initialize as -1 to indicate "not bid yet"

  // Get the number of cards per player for this round
  int get cardsPerPlayer => roundNumber;

  // Get the number of tricks in this round
  int get totalTricks => roundNumber;

  // Check if all players have bid
  bool get allBidsPlaced => bids.every((bid) => bid >= 0);

  // Check if current trick is complete (4 cards played)
  bool get isCurrentTrickComplete => currentTrick.length == 4;

  // Check if all tricks are complete
  bool get areAllTricksComplete => trickWinners.length == totalTricks;

  // Get the lead suit of the current trick
  String? get currentLeadSuit =>
      currentTrick.isNotEmpty ? currentTrick[0].suit : null;

  // Check if a player can follow suit (has cards of the lead suit)
  bool canFollowSuit(int playerIndex) {
    if (currentTrick.isEmpty)
      return true; // First card of the trick, can play anything

    String leadSuit = currentTrick[0].suit;
    List<Card> playerHand = playerHands[playerIndex];

    return playerHand.any((card) => card.suit == leadSuit);
  }

  // Get valid cards that a player can play
  List<Card> getValidCards(int playerIndex) {
    if (currentTrick.isEmpty) {
      // First card of the trick, can play any card
      return List.from(playerHands[playerIndex]);
    }

    String leadSuit = currentTrick[0].suit;
    List<Card> playerHand = playerHands[playerIndex];

    // Check if player has cards of the lead suit
    List<Card> cardsOfLeadSuit =
        playerHand.where((card) => card.suit == leadSuit).toList();

    if (cardsOfLeadSuit.isNotEmpty) {
      // Must follow suit - only allow cards of the lead suit
      return cardsOfLeadSuit;
    } else {
      // Cannot follow suit - can play any card
      return List.from(playerHand);
    }
  }

  // Validate if a card can be played by a player
  bool isValidCardPlay(Card card, int playerIndex) {
    List<Card> validCards = getValidCards(playerIndex);
    return validCards.contains(card);
  }

  // Add a card to the current trick
  Round addCardToTrick(Card card, int playerIndex) {
    // Validate the card play
    if (!isValidCardPlay(card, playerIndex)) {
      throw ArgumentError('Invalid card play: $card by player $playerIndex');
    }

    List<Card> newCurrentTrick = List.from(currentTrick);
    newCurrentTrick.add(card);

    // Remove card from player's hand
    List<List<Card>> newPlayerHands =
        playerHands.map((hand) => List<Card>.from(hand)).toList();
    newPlayerHands[playerIndex].remove(card);

    return copyWith(playerHands: newPlayerHands, currentTrick: newCurrentTrick);
  }

  // Complete the current trick and determine winner
  Round completeCurrentTrick() {
    if (!isCurrentTrickComplete) return this;

    int winnerIndex = _determineTrickWinner();
    List<int> newTrickWinners = List.from(trickWinners);
    newTrickWinners.add(winnerIndex);

    return copyWith(
      currentTrick: [],
      trickWinners: newTrickWinners,
      currentTrickIndex: currentTrickIndex + 1,
    );
  }

  // Determine the winner of the current trick
  int _determineTrickWinner() {
    if (currentTrick.length != 4) return -1;

    String leadSuit = currentTrick[0].suit;
    int winnerIndex = 0;
    Card winningCard = currentTrick[0];

    for (int i = 1; i < currentTrick.length; i++) {
      Card card = currentTrick[i];

      // Power suit beats all other suits
      if (card.suit == powerSuit && winningCard.suit != powerSuit) {
        winnerIndex = i;
        winningCard = card;
      } else if (card.suit == powerSuit && winningCard.suit == powerSuit) {
        // Both are power suit, compare values
        if (card.value > winningCard.value) {
          winnerIndex = i;
          winningCard = card;
        }
      } else if (card.suit == leadSuit && winningCard.suit != powerSuit) {
        // Both follow lead suit, compare values
        if (card.value > winningCard.value) {
          winnerIndex = i;
          winningCard = card;
        }
      }
    }

    return winnerIndex;
  }

  // Set a player's bid
  Round setBid(int playerIndex, int bid) {
    List<int> newBids = List.from(bids);
    newBids[playerIndex] = bid;

    return copyWith(bids: newBids);
  }

  // Mark round as complete
  Round markComplete() {
    return copyWith(isComplete: true);
  }

  // Get the first player to bid/play (dealer starts)
  int get firstPlayer => dealer;

  // Create a copy of the round with updated values
  Round copyWith({
    int? roundNumber,
    String? powerSuit,
    List<List<Card>>? playerHands,
    List<Card>? currentTrick,
    List<int>? trickWinners,
    List<int>? bids,
    int? currentTrickIndex,
    bool? isComplete,
    int? dealer,
  }) {
    return Round(
      roundNumber: roundNumber ?? this.roundNumber,
      powerSuit: powerSuit ?? this.powerSuit,
      playerHands:
          playerHands ??
          this.playerHands.map((hand) => List<Card>.from(hand)).toList(),
      currentTrick: currentTrick ?? List.from(this.currentTrick),
      trickWinners: trickWinners ?? List.from(this.trickWinners),
      bids: bids ?? List.from(this.bids),
      currentTrickIndex: currentTrickIndex ?? this.currentTrickIndex,
      isComplete: isComplete ?? this.isComplete,
      dealer: dealer ?? this.dealer,
    );
  }

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'powerSuit': powerSuit,
      'playerHands':
          playerHands
              .map(
                (hand) =>
                    hand
                        .map((card) => {'suit': card.suit, 'rank': card.rank})
                        .toList(),
              )
              .toList(),
      'currentTrick':
          currentTrick
              .map((card) => {'suit': card.suit, 'rank': card.rank})
              .toList(),
      'trickWinners': trickWinners,
      'bids': bids,
      'currentTrickIndex': currentTrickIndex,
      'isComplete': isComplete,
      'dealer': dealer,
    };
  }

  // Create from JSON for persistence
  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      roundNumber: json['roundNumber'] as int,
      powerSuit: json['powerSuit'] as String,
      playerHands:
          (json['playerHands'] as List)
              .map(
                (hand) =>
                    (hand as List)
                        .map(
                          (card) => Card(
                            suit: card['suit'] as String,
                            rank: card['rank'] as String,
                          ),
                        )
                        .toList(),
              )
              .toList(),
      currentTrick:
          (json['currentTrick'] as List)
              .map(
                (card) => Card(
                  suit: card['suit'] as String,
                  rank: card['rank'] as String,
                ),
              )
              .toList(),
      trickWinners: List<int>.from(json['trickWinners'] as List),
      bids: List<int>.from(json['bids'] as List),
      currentTrickIndex: json['currentTrickIndex'] as int,
      isComplete: json['isComplete'] as bool,
      dealer: json['dealer'] as int,
    );
  }
}
