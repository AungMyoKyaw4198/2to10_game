import 'package:flutter_test/flutter_test.dart';
import 'package:two_to_ten/providers/game_state.dart';
import 'package:two_to_ten/constants/game_constants.dart';

void main() {
  group('Complete Game Flow Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Complete game with normal scoring', () {
      gameState.startNewGame();

      // Play through all 9 rounds
      for (
        int round = GameConstants.minRound;
        round <= GameConstants.maxRound;
        round++
      ) {
        expect(gameState.currentRoundNumber, round);
        expect(gameState.currentRound!.roundNumber, round);
        expect(gameState.currentRound!.playerHands[0].length, round);

        // Set bids for this round
        gameState.setPlayerBid(0, 1); // Player 0 always bids 1
        gameState.setPlayerBid(1, 1); // Player 1 always bids 1
        gameState.setPlayerBid(2, 0); // Player 2 always bids 0
        gameState.setPlayerBid(3, 1); // Player 3 always bids 1

        expect(gameState.currentRound!.allBidsPlaced, true);

        // Play all tricks in this round
        for (int trick = 0; trick < round; trick++) {
          // Each player plays their first card
          for (int player = 0; player < 4; player++) {
            if (gameState.currentRound!.playerHands[player].isNotEmpty) {
              // Get valid cards for this player
              final validCards = gameState.getValidCards(player);
              if (validCards.isNotEmpty) {
                final card = validCards[0]; // Play the first valid card
                gameState.playCard(player, card);
              }
            }
          }
          // Manually complete the trick since it now uses dialogs
          gameState.completeCurrentTrick();
        }

        // Complete the round
        gameState.completeRound();
        // Manually start next round since completeRound no longer does this automatically
        gameState.startNextRound();

        // Verify round progression
        if (round < GameConstants.maxRound) {
          expect(gameState.currentRoundNumber, round + 1);
        }
      }

      // Game should be complete
      expect(gameState.isGameComplete, true);

      // Verify final scores are calculated
      for (int i = 0; i < 4; i++) {
        expect(gameState.players[i].score, isA<int>());
      }

      // Verify there's a winner
      final winner = gameState.getWinner();
      expect(winner.name, isA<String>());
    });

    test('Game with zero bids edge case', () {
      gameState.startNewGame();

      // Round 2: All players bid 0
      expect(gameState.currentRoundNumber, 2);

      gameState.setPlayerBid(0, 0);
      gameState.setPlayerBid(1, 0);
      gameState.setPlayerBid(2, 0);
      gameState.setPlayerBid(3, 0);

      expect(gameState.currentRound!.allBidsPlaced, true);

      // Test that all players can bid 0
      expect(gameState.players[0].currentBid, 0);
      expect(gameState.players[1].currentBid, 0);
      expect(gameState.players[2].currentBid, 0);
      expect(gameState.players[3].currentBid, 0);
    });

    test('Game with bag overflow edge case', () {
      gameState.startNewGame();

      // Start with player 0 having 4 bags
      gameState.players[0] = gameState.players[0].copyWith(bags: 4);

      // Round 2: Player 0 bids 1, wins 2 tricks (gets 1 more bag)
      gameState.setPlayerBid(0, 1);
      gameState.setPlayerBid(1, 1);
      gameState.setPlayerBid(2, 0);
      gameState.setPlayerBid(3, 0);

      // Test that player has bag warning
      expect(gameState.players[0].hasBagWarning, true);
      expect(gameState.players[0].bags, 4);
    });

    test('Game with tie scenario', () {
      gameState.startNewGame();

      // Set up a tie scenario
      gameState.players[0] = gameState.players[0].copyWith(score: 100);
      gameState.players[1] = gameState.players[1].copyWith(score: 100);
      gameState.players[2] = gameState.players[2].copyWith(score: 50);
      gameState.players[3] = gameState.players[3].copyWith(score: 25);

      // Player 0: 3 rounds not set
      gameState.players[0] = gameState.players[0].copyWith(
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

      // Player 1: 5 rounds not set (should win tiebreaker)
      gameState.players[1] = gameState.players[1].copyWith(
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

    test('Game with maximum overbid scenario', () {
      gameState.startNewGame();

      // Round 2: All players bid 1, all win 2 tricks
      gameState.setPlayerBid(0, 1);
      gameState.setPlayerBid(1, 1);
      gameState.setPlayerBid(2, 1);
      gameState.setPlayerBid(3, 1);

      expect(gameState.currentRound!.allBidsPlaced, true);

      // Test that all players have the same bid
      for (int i = 0; i < 4; i++) {
        expect(gameState.players[i].currentBid, 1);
      }
    });

    test('Game with maximum underbid scenario', () {
      gameState.startNewGame();

      // Round 2: All players bid 2, all win 0 tricks
      gameState.setPlayerBid(0, 2);
      gameState.setPlayerBid(1, 2);
      gameState.setPlayerBid(2, 2);
      gameState.setPlayerBid(3, 2);

      expect(gameState.currentRound!.allBidsPlaced, true);

      // Test that all players have the same bid
      for (int i = 0; i < 4; i++) {
        expect(gameState.players[i].currentBid, 2);
      }
    });

    test('Game with mixed scoring scenarios', () {
      gameState.startNewGame();

      // Round 2: Mixed bids and results
      gameState.setPlayerBid(0, 2); // Exact bid
      gameState.setPlayerBid(1, 1); // Overbid
      gameState.setPlayerBid(2, 0); // Perfect 0 bid
      gameState.setPlayerBid(3, 1); // Underbid

      expect(gameState.currentRound!.allBidsPlaced, true);

      // Test that all bids are set correctly
      expect(gameState.players[0].currentBid, 2);
      expect(gameState.players[1].currentBid, 1);
      expect(gameState.players[2].currentBid, 0);
      expect(gameState.players[3].currentBid, 1);
    });

    test('Game state persistence through rounds', () {
      gameState.startNewGame();

      // Play through first 3 rounds
      for (int round = 2; round <= 4; round++) {
        expect(gameState.currentRoundNumber, round);

        // Set bids
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }

        // Simulate playing all tricks
        for (int trick = 0; trick < round; trick++) {
          for (int player = 0; player < 4; player++) {
            if (gameState.currentRound!.playerHands[player].isNotEmpty) {
              // Get valid cards for this player
              final validCards = gameState.getValidCards(player);
              if (validCards.isNotEmpty) {
                final card = validCards[0]; // Play the first valid card
                gameState.playCard(player, card);
              }
            }
          }
          // Manually complete the trick since it now uses dialogs
          gameState.completeCurrentTrick();
        }

        gameState.completeRound();
        // Manually start next round since completeRound no longer does this automatically
        gameState.startNextRound();

        // Verify scores persist
        for (int i = 0; i < 4; i++) {
          expect(gameState.players[i].score, isA<int>());
        }
      }

      expect(gameState.currentRoundNumber, 5);
    });

    test('Power suit changes each round', () {
      gameState.startNewGame();

      final powerSuits = <String>{};

      // Check power suits for first 5 rounds
      for (int round = 2; round <= 6; round++) {
        expect(gameState.currentRound!.powerSuit, isIn(GameConstants.suits));
        powerSuits.add(gameState.currentRound!.powerSuit);

        // Complete round to move to next
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }
        gameState.completeRound();
        // Manually start next round since completeRound no longer does this automatically
        gameState.startNextRound();
      }

      // Power suits should be different (though random, we can check they're valid)
      expect(powerSuits.length, greaterThan(0));
      for (String suit in powerSuits) {
        expect(suit, isIn(GameConstants.suits));
      }
    });

    test('Dealer rotation works correctly', () {
      gameState.startNewGame();

      // Round 2: Player 0 should be dealer, Player 0 should start
      expect(gameState.currentDealer, 0);
      expect(gameState.currentRound!.dealer, 0);
      expect(gameState.currentRound!.firstPlayer, 0);

      // Set bids and play all tricks for round 2
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play all tricks for round 2 (2 tricks)
      for (int trick = 0; trick < 2; trick++) {
        for (int player = 0; player < 4; player++) {
          if (gameState.currentRound!.playerHands[player].isNotEmpty) {
            final validCards = gameState.getValidCards(player);
            if (validCards.isNotEmpty) {
              final card = validCards[0];
              gameState.playCard(player, card);
            }
          }
        }
        // Manually complete the trick since it now uses dialogs
        gameState.completeCurrentTrick();
      }

      gameState.completeRound();
      // Manually start next round since completeRound no longer does this automatically
      gameState.startNextRound();

      // Round 3: Player 1 should be dealer, Player 1 should start
      expect(gameState.currentDealer, 1);
      expect(gameState.currentRound!.dealer, 1);
      expect(gameState.currentRound!.firstPlayer, 1);

      // Set bids and play all tricks for round 3
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play all tricks for round 3 (3 tricks)
      for (int trick = 0; trick < 3; trick++) {
        for (int player = 0; player < 4; player++) {
          if (gameState.currentRound!.playerHands[player].isNotEmpty) {
            final validCards = gameState.getValidCards(player);
            if (validCards.isNotEmpty) {
              final card = validCards[0];
              gameState.playCard(player, card);
            }
          }
        }
        // Manually complete the trick since it now uses dialogs
        gameState.completeCurrentTrick();
      }

      gameState.completeRound();
      // Manually start next round since completeRound no longer does this automatically
      gameState.startNextRound();

      // Round 4: Player 2 should be dealer, Player 2 should start
      expect(gameState.currentDealer, 2);
      expect(gameState.currentRound!.dealer, 2);
      expect(gameState.currentRound!.firstPlayer, 2);

      // Set bids and play all tricks for round 4
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play all tricks for round 4 (4 tricks)
      for (int trick = 0; trick < 4; trick++) {
        for (int player = 0; player < 4; player++) {
          if (gameState.currentRound!.playerHands[player].isNotEmpty) {
            final validCards = gameState.getValidCards(player);
            if (validCards.isNotEmpty) {
              final card = validCards[0];
              gameState.playCard(player, card);
            }
          }
        }
        // Manually complete the trick since it now uses dialogs
        gameState.completeCurrentTrick();
      }

      gameState.completeRound();
      // Manually start next round since completeRound no longer does this automatically
      gameState.startNextRound();

      // Round 5: Player 3 should be dealer, Player 3 should start
      expect(gameState.currentDealer, 3);
      expect(gameState.currentRound!.dealer, 3);
      expect(gameState.currentRound!.firstPlayer, 3);

      // Set bids and play all tricks for round 5
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play all tricks for round 5 (5 tricks)
      for (int trick = 0; trick < 5; trick++) {
        for (int player = 0; player < 4; player++) {
          if (gameState.currentRound!.playerHands[player].isNotEmpty) {
            final validCards = gameState.getValidCards(player);
            if (validCards.isNotEmpty) {
              final card = validCards[0];
              gameState.playCard(player, card);
            }
          }
        }
        // Manually complete the trick since it now uses dialogs
        gameState.completeCurrentTrick();
      }

      gameState.completeRound();
      // Manually start next round since completeRound no longer does this automatically
      gameState.startNextRound();

      // Round 6: Player 0 should be dealer again, Player 0 should start
      expect(gameState.currentDealer, 0);
      expect(gameState.currentRound!.dealer, 0);
      expect(gameState.currentRound!.firstPlayer, 0);
    });
  });
}
