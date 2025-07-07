import 'card.dart';

class Round {
  final int roundNumber;
  final Card powerCard; // Changed from powerSuit to powerCard
  final List<List<Card>> playerHands;
  final List<Card> currentTrick;
  final List<int> currentTrickPlayers; // Track which player played each card
  final List<int> trickWinners;
  final List<int> bids;
  final int currentTrickIndex;
  final bool isComplete;
  final int dealer; // Track the dealer for this round

  Round({
    required this.roundNumber,
    required this.powerCard, // Changed from powerSuit to powerCard
    required this.playerHands,
    List<Card>? currentTrick,
    List<int>? currentTrickPlayers,
    List<int>? trickWinners,
    List<int>? bids,
    this.currentTrickIndex = 0,
    this.isComplete = false,
    required this.dealer,
  }) : currentTrick = currentTrick ?? [],
       currentTrickPlayers = currentTrickPlayers ?? [],
       trickWinners = trickWinners ?? [],
       bids =
           bids ??
           List.filled(4, -1); // Initialize as -1 to indicate "not bid yet"

  // Get the power suit from the power card
  String get powerSuit => powerCard.suit;

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

  // Get the first player of the current trick (who leads)
  int? get currentTrickFirstPlayer =>
      currentTrickPlayers.isNotEmpty ? currentTrickPlayers[0] : null;

  // Check if a player can follow suit (has cards of the lead suit)
  bool canFollowSuit(int playerIndex) {
    if (currentTrick.isEmpty) return true; // No lead suit yet
    String leadSuit = currentTrick[0].suit;
    return playerHands[playerIndex].any((card) => card.suit == leadSuit);
  }

  // Get valid cards that a player can play
  List<Card> getValidCards(int playerIndex) {
    if (currentTrick.isEmpty) {
      // First player can play any card
      return List.from(playerHands[playerIndex]);
    }

    String leadSuit = currentTrick[0].suit;
    List<Card> cardsOfLeadSuit =
        playerHands[playerIndex]
            .where((card) => card.suit == leadSuit)
            .toList();

    if (cardsOfLeadSuit.isNotEmpty) {
      // Must follow suit
      return cardsOfLeadSuit;
    } else {
      // Can play any card
      return List.from(playerHands[playerIndex]);
    }
  }

  // Check if a card is valid for a player to play
  bool isValidCardPlay(Card card, int playerIndex) {
    return getValidCards(playerIndex).contains(card);
  }

  // Add a card to the current trick
  Round addCardToTrick(Card card, int playerIndex) {
    if (!isValidCardPlay(card, playerIndex)) {
      throw ArgumentError('Invalid card play: $card by player $playerIndex');
    }

    List<Card> newCurrentTrick = List.from(currentTrick)..add(card);
    List<int> newCurrentTrickPlayers = List.from(currentTrickPlayers)
      ..add(playerIndex);

    // Remove the card from the player's hand
    List<List<Card>> newPlayerHands =
        playerHands.map((hand) {
          List<Card> newHand = List.from(hand);
          newHand.remove(card);
          return newHand;
        }).toList();

    return copyWith(
      currentTrick: newCurrentTrick,
      currentTrickPlayers: newCurrentTrickPlayers,
      playerHands: newPlayerHands,
    );
  }

  // Complete the current trick and move to the next
  Round completeCurrentTrick() {
    if (!isCurrentTrickComplete) {
      throw StateError('Cannot complete incomplete trick');
    }

    int winnerIndex = determineTrickWinner();
    List<int> newTrickWinners = List.from(trickWinners)..add(winnerIndex);

    return copyWith(
      currentTrick: [],
      currentTrickPlayers: [],
      currentTrickIndex: currentTrickIndex + 1,
      trickWinners: newTrickWinners,
    );
  }

  // Determine the winner of a trick
  int determineTrickWinner([List<Card>? trick, List<int>? trickPlayers]) {
    final cards = trick ?? currentTrick;
    final players = trickPlayers ?? currentTrickPlayers;

    if (cards.length != 4 || players.length != 4) return -1;

    String leadSuit = cards[0].suit;
    int winnerIndex = players[0]; // Use actual player index, not 0
    Card winningCard = cards[0];

    for (int i = 1; i < cards.length; i++) {
      Card card = cards[i];
      int currentPlayerIndex = players[i]; // Use actual player index

      // Power suit beats all other suits
      if (card.suit == powerCard.suit && winningCard.suit != powerCard.suit) {
        winnerIndex = currentPlayerIndex;
        winningCard = card;
      } else if (card.suit == powerCard.suit &&
          winningCard.suit == powerCard.suit) {
        // Both are power suit, compare values using power card ranking
        if (_comparePowerSuitCards(card, winningCard) > 0) {
          winnerIndex = currentPlayerIndex;
          winningCard = card;
        }
      } else if (card.suit == leadSuit && winningCard.suit != powerCard.suit) {
        // Both follow lead suit, compare values
        if (card.value > winningCard.value) {
          winnerIndex = currentPlayerIndex;
          winningCard = card;
        }
      }
    }
    return winnerIndex;
  }

  // Compare two cards of the power suit using the power card's rank as highest
  int _comparePowerSuitCards(Card card1, Card card2) {
    if (card1.suit != powerCard.suit || card2.suit != powerCard.suit) {
      throw ArgumentError('Both cards must be of the power suit');
    }

    // If either card is the power card, it wins
    if (card1.rank == powerCard.rank && card2.rank != powerCard.rank) {
      return 1; // card1 wins
    }
    if (card2.rank == powerCard.rank && card1.rank != powerCard.rank) {
      return -1; // card2 wins
    }
    if (card1.rank == powerCard.rank && card2.rank == powerCard.rank) {
      return 0; // tie (shouldn't happen in practice)
    }

    // For other cards in the power suit, use normal ranking
    // but treat the power card's rank as the highest
    int card1Value = _getPowerSuitCardValue(card1);
    int card2Value = _getPowerSuitCardValue(card2);

    return card1Value.compareTo(card2Value);
  }

  // Get the value of a card in the power suit, considering the power card as highest
  int _getPowerSuitCardValue(Card card) {
    if (card.rank == powerCard.rank) {
      return 15; // Power card is highest
    }

    // For other cards, use normal ranking but ensure power card rank is treated as highest
    int normalValue = card.value;
    int powerCardNormalValue = powerCard.value;

    if (normalValue >= powerCardNormalValue) {
      return normalValue + 1; // Shift up to make room for power card
    }
    return normalValue;
  }

  // Get the first player to bid/play (dealer starts for first trick, then winner of previous trick)
  int get firstPlayer {
    if (trickWinners.isEmpty) {
      return dealer; // Dealer starts the first trick
    } else {
      return trickWinners.last; // Winner of previous trick starts
    }
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

  // Create a copy of the round with updated values
  Round copyWith({
    int? roundNumber,
    Card? powerCard, // Changed from powerSuit to powerCard
    List<List<Card>>? playerHands,
    List<Card>? currentTrick,
    List<int>? currentTrickPlayers,
    List<int>? trickWinners,
    List<int>? bids,
    int? currentTrickIndex,
    bool? isComplete,
    int? dealer,
  }) {
    return Round(
      roundNumber: roundNumber ?? this.roundNumber,
      powerCard:
          powerCard ?? this.powerCard, // Changed from powerSuit to powerCard
      playerHands:
          playerHands ??
          this.playerHands.map((hand) => List<Card>.from(hand)).toList(),
      currentTrick: currentTrick ?? List.from(this.currentTrick),
      currentTrickPlayers:
          currentTrickPlayers ?? List.from(this.currentTrickPlayers),
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
      'powerCard': {
        'suit': powerCard.suit,
        'rank': powerCard.rank,
      }, // Changed from powerSuit
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
      'currentTrickPlayers': currentTrickPlayers,
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
      powerCard: Card(
        // Changed from powerSuit
        suit: json['powerCard']['suit'] as String,
        rank: json['powerCard']['rank'] as String,
      ),
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
      currentTrickPlayers: List<int>.from(json['currentTrickPlayers'] as List),
      trickWinners: List<int>.from(json['trickWinners'] as List),
      bids: List<int>.from(json['bids'] as List),
      currentTrickIndex: json['currentTrickIndex'] as int,
      isComplete: json['isComplete'] as bool,
      dealer: json['dealer'] as int,
    );
  }
}
