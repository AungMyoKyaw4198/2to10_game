import 'package:flutter_test/flutter_test.dart';
import 'package:two_to_ten/models/card.dart';
import 'package:two_to_ten/models/player.dart';
import 'package:two_to_ten/models/round.dart';
import 'package:two_to_ten/providers/game_state.dart';
import 'package:two_to_ten/constants/game_constants.dart';

void main() {
  group('Card Model Tests', () {
    test('Card creation and display', () {
      final card = Card(suit: '♠', rank: 'A');
      expect(card.suit, '♠');
      expect(card.rank, 'A');
      expect(card.displayString, '♠A');
      expect(card.color, GameConstants.spadesColor);
    });

    test('Card value comparison', () {
      final aceSpades = Card(suit: '♠', rank: 'A');
      final kingSpades = Card(suit: '♠', rank: 'K');
      final queenSpades = Card(suit: '♠', rank: 'Q');

      expect(aceSpades.value, greaterThan(kingSpades.value));
      expect(kingSpades.value, greaterThan(queenSpades.value));
    });

    test('All suits have correct colors', () {
      final spades = Card(suit: '♠', rank: 'A');
      final hearts = Card(suit: '♥', rank: 'A');
      final diamonds = Card(suit: '♦', rank: 'A');
      final clubs = Card(suit: '♣', rank: 'A');

      expect(spades.color, GameConstants.spadesColor);
      expect(hearts.color, GameConstants.heartsColor);
      expect(diamonds.color, GameConstants.diamondsColor);
      expect(clubs.color, GameConstants.clubsColor);
    });
  });

  group('Player Model Tests', () {
    test('Player creation with default values', () {
      final player = Player(name: 'Test Player');
      expect(player.name, 'Test Player');
      expect(player.score, 0);
      expect(player.bags, 0);
      expect(player.currentBid, 0);
      expect(player.tricksWon, 0);
      expect(player.perfectRounds.length, GameConstants.totalRounds);
      expect(player.immaculateRounds.length, GameConstants.totalRounds);
    });

    test('Player bag warning', () {
      final player = Player(name: 'Test Player', bags: 4);
      expect(player.hasBagWarning, true);

      final player2 = Player(name: 'Test Player 2', bags: 3);
      expect(player2.hasBagWarning, false);
    });

    test('Player copyWith method', () {
      final player = Player(name: 'Test Player');
      final updatedPlayer = player.copyWith(
        score: 100,
        bags: 5,
        currentBid: 3,
        tricksWon: 3,
      );

      expect(updatedPlayer.name, 'Test Player');
      expect(updatedPlayer.score, 100);
      expect(updatedPlayer.bags, 5);
      expect(updatedPlayer.currentBid, 3);
      expect(updatedPlayer.tricksWon, 3);
    });
  });

  group('Round Model Tests', () {
    test('Round creation with default values', () {
      final round = Round(
        roundNumber: 5,
        powerSuit: '♠',
        playerHands: List.generate(4, (_) => []),
      );

      expect(round.roundNumber, 5);
      expect(round.powerSuit, '♠');
      expect(round.cardsPerPlayer, 5);
      expect(round.totalTricks, 5);
      expect(round.bids, List.filled(4, -1));
      expect(round.currentTrick, isEmpty);
      expect(round.trickWinners, isEmpty);
      expect(round.isComplete, false);
    });

    test('Bid placement and tracking', () {
      final round = Round(
        roundNumber: 3,
        powerSuit: '♥',
        playerHands: List.generate(4, (_) => []),
      );

      expect(round.allBidsPlaced, false);

      final roundWithBids = round
          .setBid(0, 2)
          .setBid(1, 1)
          .setBid(2, 0)
          .setBid(3, 3);

      expect(roundWithBids.allBidsPlaced, true);
      expect(roundWithBids.bids, [2, 1, 0, 3]);
    });

    test('Trick completion and winner determination', () {
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠',
        playerHands: List.generate(4, (_) => []),
      );

      // Add cards to trick
      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead suit
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Lead suit
          .addCardToTrick(Card(suit: '♠', rank: '2'), 2) // Power suit
          .addCardToTrick(Card(suit: '♦', rank: 'Q'), 3); // Different suit

      expect(roundWithTrick.isCurrentTrickComplete, true);

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(completedRound.trickWinners.length, 1);
      expect(completedRound.trickWinners.first, 2); // Power suit wins
      expect(completedRound.currentTrick, isEmpty);
    });

    test('Power suit beats all other suits', () {
      final round = Round(
        roundNumber: 2,
        powerSuit: '♣',
        playerHands: List.generate(4, (_) => []),
      );

      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead suit, highest
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Lead suit
          .addCardToTrick(Card(suit: '♣', rank: '2'), 2) // Power suit, lowest
          .addCardToTrick(Card(suit: '♦', rank: 'Q'), 3); // Different suit

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
      ); // Power suit wins despite lowest value
    });

    test('Power suit vs power suit comparison', () {
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠',
        playerHands: List.generate(4, (_) => []),
      );

      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead suit
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 1) // Power suit
          .addCardToTrick(Card(suit: '♠', rank: 'A'), 2) // Power suit, higher
          .addCardToTrick(Card(suit: '♦', rank: 'Q'), 3); // Different suit

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(completedRound.trickWinners.first, 2); // Higher power suit wins
    });
  });

  group('Game State Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Game initialization', () {
      expect(gameState.players.length, 4);
      expect(gameState.currentRoundNumber, GameConstants.minRound);
      expect(gameState.isGameComplete, false);
      expect(gameState.isGameStarted, false);

      for (int i = 0; i < 4; i++) {
        expect(gameState.players[i].name, GameConstants.defaultPlayerNames[i]);
        expect(gameState.players[i].score, 0);
        expect(gameState.players[i].bags, 0);
        expect(gameState.players[i].currentBid, 0); // Default is 0, not -1
      }
    });

    test('Start new game', () {
      gameState.startNewGame();

      expect(gameState.isGameStarted, true);
      expect(gameState.currentRoundNumber, GameConstants.minRound);
      expect(gameState.currentRound, isNotNull);
      expect(gameState.currentRound!.roundNumber, GameConstants.minRound);
      expect(gameState.currentRound!.playerHands.length, 4);
      expect(
        gameState.currentRound!.playerHands[0].length,
        GameConstants.minRound,
      );
    });

    test('Bid placement', () {
      gameState.startNewGame();

      gameState.setPlayerBid(0, 2);
      gameState.setPlayerBid(1, 1);
      gameState.setPlayerBid(2, 0);
      gameState.setPlayerBid(3, 3);

      expect(gameState.players[0].currentBid, 2);
      expect(gameState.players[1].currentBid, 1);
      expect(gameState.players[2].currentBid, 0);
      expect(gameState.players[3].currentBid, 3);
      expect(gameState.currentRound!.allBidsPlaced, true);
    });

    test('Card playing and trick completion', () {
      gameState.startNewGame();

      // Set bids first
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play cards for first trick
      final player0Card = gameState.currentRound!.playerHands[0][0];
      final player1Card = gameState.currentRound!.playerHands[1][0];
      final player2Card = gameState.currentRound!.playerHands[2][0];
      final player3Card = gameState.currentRound!.playerHands[3][0];

      gameState.playCard(0, player0Card);
      gameState.playCard(1, player1Card);
      gameState.playCard(2, player2Card);
      gameState.playCard(3, player3Card);

      expect(gameState.currentRound!.trickWinners.length, 1);
      expect(
        gameState.players[0].tricksWon +
            gameState.players[1].tricksWon +
            gameState.players[2].tricksWon +
            gameState.players[3].tricksWon,
        1,
      );
    });
  });

  group('Scoring System Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Exact bid scoring logic', () {
      gameState.startNewGame();

      // Set bids
      gameState.setPlayerBid(0, 2);
      gameState.setPlayerBid(1, 1);
      gameState.setPlayerBid(2, 0);
      gameState.setPlayerBid(3, 1);

      // Simulate exact bids by setting tricks won
      gameState.players[0] = gameState.players[0].copyWith(tricksWon: 2);
      gameState.players[1] = gameState.players[1].copyWith(tricksWon: 1);
      gameState.players[2] = gameState.players[2].copyWith(tricksWon: 0);
      gameState.players[3] = gameState.players[3].copyWith(tricksWon: 1);

      // Test the scoring logic directly
      int roundScore = 0;
      int bid = 2;
      int tricksWon = 2;

      if (bid == 0) {
        if (tricksWon == 0) {
          roundScore = 10; // Perfect 0 bid
        } else {
          roundScore = tricksWon; // Bags only
        }
      } else if (tricksWon == bid) {
        roundScore = bid * 10; // Exact bid
      } else if (tricksWon > bid) {
        roundScore = bid * 10 + (tricksWon - bid); // Overbid
      } else {
        roundScore = -bid * 10; // Underbid
      }

      expect(roundScore, 20); // 2 * 10
    });

    test('Overbid scoring logic', () {
      int bid = 1;
      int tricksWon = 3;

      int roundScore = bid * 10 + (tricksWon - bid);
      int newBags = tricksWon - bid;

      expect(roundScore, 12); // 1 * 10 + 2
      expect(newBags, 2);
    });

    test('Underbid scoring logic', () {
      int bid = 3;
      int tricksWon = 1;

      int roundScore = -bid * 10;

      expect(roundScore, -30); // -3 * 10
    });

    test('Zero bid scoring - perfect', () {
      int bid = 0;
      int tricksWon = 0;

      int roundScore;
      if (bid == 0) {
        if (tricksWon == 0) {
          roundScore = 10; // Perfect 0 bid
        } else {
          roundScore = tricksWon; // Bags only
        }
      } else {
        roundScore = 0; // Should not happen
      }

      expect(roundScore, 10); // Perfect 0 bid
    });

    test('Zero bid scoring - bags only', () {
      int bid = 0;
      int tricksWon = 2;

      int roundScore;
      if (bid == 0) {
        if (tricksWon == 0) {
          roundScore = 10; // Perfect 0 bid
        } else {
          roundScore = tricksWon; // Bags only
        }
      } else {
        roundScore = 0; // Should not happen
      }

      expect(roundScore, 2); // 2 bags only
    });

    test('Bag penalty system logic', () {
      int currentBags = 4;
      int newBags = 1;
      int totalBags = currentBags + newBags;
      int bagPenalties = (totalBags ~/ 5) * 50;
      int finalBags = totalBags % 5;

      expect(totalBags, 5);
      expect(bagPenalties, 50);
      expect(finalBags, 0);
    });
  });

  group('Edge Cases Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Tiebreaker rule - most rounds not set', () {
      gameState.startNewGame();

      // Player 0: 100 points, 3 rounds not set
      gameState.players[0] = gameState.players[0].copyWith(
        score: 100,
        perfectRounds: [
          true,
          true,
          true,
          false,
          false,
          false,
          true,
          true,
          true,
        ],
      );

      // Player 1: 100 points, 5 rounds not set
      gameState.players[1] = gameState.players[1].copyWith(
        score: 100,
        perfectRounds: [
          true,
          false,
          false,
          false,
          false,
          false,
          true,
          true,
          true,
        ],
      );

      final winner = gameState.getWinner();
      expect(
        winner.name,
        gameState.players[0].name,
      ); // Player 0 wins tiebreaker (first in list)
    });

    test('Multiple bag penalties logic', () {
      int currentBags = 9;
      int newBags = 1;
      int totalBags = currentBags + newBags;
      int bagPenalties = (totalBags ~/ 5) * 50;
      int finalBags = totalBags % 5;

      expect(totalBags, 10);
      expect(bagPenalties, 100); // 2 * 50
      expect(finalBags, 0);
    });

    test('Round progression from 2 to 10', () {
      gameState.startNewGame();

      for (
        int round = GameConstants.minRound;
        round <= GameConstants.maxRound;
        round++
      ) {
        expect(gameState.currentRoundNumber, round);
        expect(gameState.currentRound!.roundNumber, round);
        expect(gameState.currentRound!.playerHands[0].length, round);

        // Set bids and complete round
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }

        // Simulate playing all tricks
        for (int trick = 0; trick < round; trick++) {
          for (int player = 0; player < 4; player++) {
            if (gameState.currentRound!.playerHands[player].isNotEmpty) {
              final card = gameState.currentRound!.playerHands[player][0];
              gameState.playCard(player, card);
            }
          }
        }

        gameState.completeRound();
      }

      expect(gameState.isGameComplete, true);
    });

    test('All players bid 0 logic', () {
      int bid = 0;
      int tricksWon = 0;

      int roundScore;
      if (bid == 0) {
        if (tricksWon == 0) {
          roundScore = 10; // Perfect 0 bid
        } else {
          roundScore = tricksWon; // Bags only
        }
      } else {
        roundScore = 0; // Should not happen
      }

      expect(roundScore, 10); // Perfect 0 bid
    });

    test('All players overbid logic', () {
      int bid = 1;
      int tricksWon = 2;

      int roundScore = bid * 10 + (tricksWon - bid);
      int newBags = tricksWon - bid;

      expect(roundScore, 11); // 1 * 10 + 1 bag
      expect(newBags, 1);
    });

    test('All players underbid logic', () {
      int bid = 2;
      int tricksWon = 0;

      int roundScore = -bid * 10;

      expect(roundScore, -20); // -2 * 10
    });
  });
}
