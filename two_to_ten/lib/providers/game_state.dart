import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../constants/game_constants.dart';

class GameState extends ChangeNotifier {
  List<Player> _players = [];
  Round? _currentRound;
  int _currentRoundNumber = GameConstants.minRound;
  bool _isGameComplete = false;
  bool _isGameStarted = false;

  // Getters
  List<Player> get players => _players;
  Round? get currentRound => _currentRound;
  int get currentRoundNumber => _currentRoundNumber;
  bool get isGameComplete => _isGameComplete;
  bool get isGameStarted => _isGameStarted;
  bool get isGameInProgress => _isGameStarted && !_isGameComplete;

  GameState() {
    _initializePlayers();
  }

  // Initialize players with default names
  void _initializePlayers() {
    _players =
        GameConstants.defaultPlayerNames
            .map((name) => Player(name: name))
            .toList();
  }

  // Start a new game
  void startNewGame() {
    _currentRoundNumber = GameConstants.minRound;
    _isGameComplete = false;
    _isGameStarted = true;

    // Reset all players
    for (int i = 0; i < _players.length; i++) {
      _players[i] = Player(name: _players[i].name);
    }

    _startNewRound();
    notifyListeners();
  }

  // Start a new round
  void _startNewRound() {
    if (_currentRoundNumber > GameConstants.maxRound) {
      _isGameComplete = true;
      _calculateFinalScores();
      notifyListeners();
      return;
    }

    // Reset player bids and tricks for the new round
    _resetPlayerRoundData();

    // Deal cards for the current round
    List<List<Card>> playerHands = _dealCards(_currentRoundNumber);

    // Select random power suit
    String powerSuit =
        GameConstants.suits[Random().nextInt(GameConstants.suits.length)];

    _currentRound = Round(
      roundNumber: _currentRoundNumber,
      powerSuit: powerSuit,
      playerHands: playerHands,
    );

    notifyListeners();
  }

  // Reset player bids and tricks for a new round
  void _resetPlayerRoundData() {
    for (int i = 0; i < _players.length; i++) {
      _players[i] = _players[i].copyWith(
        currentBid: -1, // Reset to -1 to indicate "not bid yet"
        tricksWon: 0, // Reset tricks won for the new round
      );
    }
  }

  // Deal cards to players
  List<List<Card>> _dealCards(int cardsPerPlayer) {
    List<Card> deck = _createDeck();
    deck.shuffle();

    List<List<Card>> hands = List.generate(4, (_) => <Card>[]);

    for (int i = 0; i < cardsPerPlayer * 4; i++) {
      hands[i % 4].add(deck[i]);
    }

    return hands;
  }

  // Create a standard 52-card deck
  List<Card> _createDeck() {
    List<Card> deck = [];
    for (String suit in GameConstants.suits) {
      for (String rank in GameConstants.ranks) {
        deck.add(Card(suit: suit, rank: rank));
      }
    }
    return deck;
  }

  // Set a player's bid
  void setPlayerBid(int playerIndex, int bid) {
    if (_currentRound == null) return;

    _currentRound = _currentRound!.setBid(playerIndex, bid);
    _players[playerIndex] = _players[playerIndex].copyWith(currentBid: bid);

    notifyListeners();
  }

  // Play a card
  void playCard(int playerIndex, Card card) {
    if (_currentRound == null) return;

    try {
      _currentRound = _currentRound!.addCardToTrick(card, playerIndex);

      // If trick is complete, determine winner and update player stats
      if (_currentRound!.isCurrentTrickComplete) {
        _currentRound = _currentRound!.completeCurrentTrick();

        // Update trick count for the winner
        int winnerIndex = _currentRound!.trickWinners.last;
        _players[winnerIndex] = _players[winnerIndex].copyWith(
          tricksWon: _players[winnerIndex].tricksWon + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      // Handle invalid card play - could show error message to user
      print('Invalid card play: $e');
      // For now, just ignore the invalid play
    }
  }

  // Get valid cards that a player can play
  List<Card> getValidCards(int playerIndex) {
    if (_currentRound == null) return [];
    return _currentRound!.getValidCards(playerIndex);
  }

  // Check if a card is valid for a player to play
  bool isValidCardPlay(Card card, int playerIndex) {
    if (_currentRound == null) return false;
    return _currentRound!.isValidCardPlay(card, playerIndex);
  }

  // Complete the current round
  void completeRound() {
    if (_currentRound == null || !_currentRound!.areAllTricksComplete) return;

    _currentRound = _currentRound!.markComplete();
    _calculateRoundScores();
    _currentRoundNumber++;

    _startNewRound();
  }

  // Calculate scores for the current round
  void _calculateRoundScores() {
    for (int i = 0; i < _players.length; i++) {
      Player player = _players[i];
      int bid = player.currentBid;
      int tricksWon = player.tricksWon;
      int roundIndex = _currentRoundNumber - GameConstants.minRound;

      int roundScore = 0;
      int newBags = 0;
      bool isPerfect = false;
      bool isImmaculate = false;

      if (bid == 0) {
        if (tricksWon == 0) {
          roundScore = 10; // Perfect 0 bid
          isImmaculate = true;
        } else {
          roundScore = tricksWon; // Bags only
          newBags = tricksWon;
        }
      } else if (tricksWon == bid) {
        roundScore = bid * GameConstants.exactBidBonus; // Exact bid
        isPerfect = true;
      } else if (tricksWon > bid) {
        roundScore =
            bid * GameConstants.exactBidBonus + (tricksWon - bid); // Overbid
        newBags = tricksWon - bid;
      } else {
        roundScore = -bid * GameConstants.exactBidBonus; // Underbid
      }

      // Update player stats
      int totalBags = player.bags + newBags;
      int bagPenalties =
          (totalBags ~/ GameConstants.bagsForPenalty) *
          GameConstants.bagPenalty;
      int finalScore = player.score + roundScore - bagPenalties;

      List<bool> newPerfectRounds = List.from(player.perfectRounds);
      newPerfectRounds[roundIndex] = isPerfect;

      List<bool> newImmaculateRounds = List.from(player.immaculateRounds);
      newImmaculateRounds[roundIndex] = isImmaculate;

      _players[i] = player.copyWith(
        score: finalScore,
        bags: totalBags % GameConstants.bagsForPenalty,
        perfectRounds: newPerfectRounds,
        immaculateRounds: newImmaculateRounds,
      );
    }
  }

  // Calculate final scores and determine winner
  void _calculateFinalScores() {
    // Apply Perfect Game bonus
    for (int i = 0; i < _players.length; i++) {
      Player player = _players[i];
      if (player.perfectRounds.every((perfect) => perfect)) {
        _players[i] = player.copyWith(
          score: player.score + GameConstants.perfectGameBonus,
        );
      }
    }

    // Apply Immaculate Game bonus
    for (int i = 0; i < _players.length; i++) {
      Player player = _players[i];
      if (player.immaculateRounds.every((immaculate) => immaculate)) {
        _players[i] = player.copyWith(
          score: player.score + GameConstants.immaculateGameBonus,
        );
      }
    }
  }

  // Get the winner (with tiebreaker)
  Player getWinner() {
    if (_players.isEmpty) return Player(name: 'No Players');

    Player winner = _players[0];
    int maxScore = winner.score;
    int maxRoundsNotSet = winner.roundsNotSet;

    for (int i = 1; i < _players.length; i++) {
      Player player = _players[i];
      if (player.score > maxScore) {
        winner = player;
        maxScore = player.score;
        maxRoundsNotSet = player.roundsNotSet;
      } else if (player.score == maxScore) {
        // Tiebreaker: most rounds not set
        if (player.roundsNotSet > maxRoundsNotSet) {
          winner = player;
          maxRoundsNotSet = player.roundsNotSet;
        }
      }
    }

    return winner;
  }
}
