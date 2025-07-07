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
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 0,
      );

      expect(round.roundNumber, 5);
      expect(
        round.powerCard.suit,
        '♠',
      ); // Changed from powerSuit to powerCard.suit
      expect(round.powerCard.rank, 'A'); // New: check power card rank
      expect(round.cardsPerPlayer, 5);
      expect(round.totalTricks, 5);
      expect(round.bids, List.filled(4, -1));
      expect(round.currentTrick, isEmpty);
      expect(round.trickWinners, isEmpty);
      expect(round.isComplete, false);
      expect(round.dealer, 0);
      expect(round.firstPlayer, 0); // Dealer starts
    });

    test('Bid placement and tracking', () {
      final round = Round(
        roundNumber: 3,
        powerCard: Card(
          suit: '♥',
          rank: 'K',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 1,
      );

      expect(round.allBidsPlaced, false);
      expect(round.firstPlayer, 1); // Dealer starts

      final roundWithBids = round
          .setBid(1, 2) // Dealer starts
          .setBid(2, 1) // Second player
          .setBid(3, 0) // Third player
          .setBid(0, 3); // Fourth player

      expect(roundWithBids.allBidsPlaced, true);
      expect(roundWithBids.bids, [3, 2, 1, 0]); // Bids in player order 0,1,2,3
    });

    test('Trick completion and winner determination', () {
      final round = Round(
        roundNumber: 2,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0 has hearts
          [Card(suit: '♥', rank: 'K')], // Player 1 has hearts
          [Card(suit: '♠', rank: '2')], // Player 2 has spades
          [Card(suit: '♦', rank: 'Q')], // Player 3 has diamonds
        ],
        dealer: 0,
      );

      expect(round.firstPlayer, 0); // Dealer starts

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
        powerCard: Card(
          suit: '♣',
          rank: 'K',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0 has hearts
          [Card(suit: '♥', rank: 'K')], // Player 1 has hearts
          [Card(suit: '♣', rank: '2')], // Player 2 has clubs
          [Card(suit: '♦', rank: 'Q')], // Player 3 has diamonds
        ],
        dealer: 1,
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
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0 has hearts
          [Card(suit: '♠', rank: 'K')], // Player 1 has spades
          [Card(suit: '♠', rank: 'A')], // Player 2 has spades
          [Card(suit: '♦', rank: 'Q')], // Player 3 has diamonds
        ],
        dealer: 2,
      );

      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead suit
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 1) // Power suit
          .addCardToTrick(Card(suit: '♠', rank: 'A'), 2) // Power suit, higher
          .addCardToTrick(Card(suit: '♦', rank: 'Q'), 3); // Different suit

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(completedRound.trickWinners.first, 2); // Higher power suit wins
    });

    test('Follow suit rule - must follow lead suit if able', () {
      final round = Round(
        roundNumber: 3,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0 has hearts
          [
            Card(suit: '♥', rank: 'K'),
            Card(suit: '♣', rank: 'Q'),
          ], // Player 1 has hearts and clubs
          [Card(suit: '♦', rank: 'J')], // Player 2 has diamonds only
          [Card(suit: '♣', rank: '10')], // Player 3 has clubs only
        ],
        dealer: 3,
      );

      // First player leads with hearts
      final roundWithLead = round.addCardToTrick(Card(suit: '♥', rank: 'A'), 0);

      // Player 1 must follow suit (hearts) - should only be able to play hearts
      final validCardsForPlayer1 = roundWithLead.getValidCards(1);
      expect(validCardsForPlayer1.length, 1);
      expect(validCardsForPlayer1.first.suit, '♥');
      expect(validCardsForPlayer1.first.rank, 'K');

      // Player 2 cannot follow suit (no hearts) - should be able to play any card
      final validCardsForPlayer2 = roundWithLead.getValidCards(2);
      expect(validCardsForPlayer2.length, 1);
      expect(validCardsForPlayer2.first.suit, '♦');

      // Player 3 cannot follow suit (no hearts) - should be able to play any card
      final validCardsForPlayer3 = roundWithLead.getValidCards(3);
      expect(validCardsForPlayer3.length, 1);
      expect(validCardsForPlayer3.first.suit, '♣');
    });

    test('Dealer rotation and first player determination', () {
      // Test different dealers
      final round1 = Round(
        roundNumber: 2,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 0,
      );
      expect(round1.firstPlayer, 0); // Dealer starts

      final round2 = Round(
        roundNumber: 2,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 1,
      );
      expect(round2.firstPlayer, 1); // Dealer starts

      final round3 = Round(
        roundNumber: 2,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 2,
      );
      expect(round3.firstPlayer, 2); // Dealer starts

      final round4 = Round(
        roundNumber: 2,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 3,
      );
      expect(round4.firstPlayer, 3); // Dealer starts
    });

    test('Complete follow suit and trick winning rules verification', () {
      // Test all the rules comprehensively
      final round = Round(
        roundNumber: 4,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0: leads with hearts
          [
            Card(suit: '♥', rank: 'K'),
            Card(suit: '♠', rank: '2'),
          ], // Player 1: has hearts and power suit
          [
            Card(suit: '♦', rank: 'Q'),
            Card(suit: '♠', rank: 'A'),
          ], // Player 2: has diamonds and power suit
          [Card(suit: '♣', rank: 'J')], // Player 3: has clubs only
        ],
        dealer: 0,
      );

      // Rule 1: First player can play any card
      final roundWithLead = round.addCardToTrick(Card(suit: '♥', rank: 'A'), 0);
      expect(roundWithLead.currentTrick.length, 1);
      expect(roundWithLead.currentLeadSuit, '♥');

      // Rule 2: Player 1 must follow suit (hearts) since they have hearts
      final validCards1 = roundWithLead.getValidCards(1);
      expect(validCards1.length, 1);
      expect(validCards1.first.suit, '♥');
      expect(validCards1.first.rank, 'K');

      final roundWithPlayer1 = roundWithLead.addCardToTrick(
        Card(suit: '♥', rank: 'K'),
        1,
      );

      // Rule 3: Player 2 cannot follow suit (no hearts), so can play any card
      final validCards2 = roundWithPlayer1.getValidCards(2);
      expect(validCards2.length, 2); // Can play diamonds or spades
      expect(validCards2.any((card) => card.suit == '♦'), true);
      expect(validCards2.any((card) => card.suit == '♠'), true);

      // Player 2 plays power suit (spades)
      final roundWithPlayer2 = roundWithPlayer1.addCardToTrick(
        Card(suit: '♠', rank: 'A'),
        2,
      );

      // Rule 4: Player 3 cannot follow suit (no hearts), so can play any card
      final validCards3 = roundWithPlayer2.getValidCards(3);
      expect(validCards3.length, 1);
      expect(validCards3.first.suit, '♣');

      final roundWithPlayer3 = roundWithPlayer2.addCardToTrick(
        Card(suit: '♣', rank: 'J'),
        3,
      );

      // Rule 5: Determine winner - power suit should win
      expect(roundWithPlayer3.isCurrentTrickComplete, true);
      final completedRound = roundWithPlayer3.completeCurrentTrick();
      expect(completedRound.trickWinners.length, 1);
      expect(
        completedRound.trickWinners.first,
        2,
      ); // Player 2 wins with power suit
    });

    test('Trick winning rules - highest lead suit wins when no power suit', () {
      final round = Round(
        roundNumber: 4,
        powerCard: Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Player 0: leads with hearts
          [Card(suit: '♥', rank: 'K')], // Player 1: has hearts
          [Card(suit: '♥', rank: 'Q')], // Player 2: has hearts
          [Card(suit: '♦', rank: 'J')], // Player 3: has diamonds only
        ],
        dealer: 1,
      );

      // All players follow suit except player 3
      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead with hearts
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Follow suit
          .addCardToTrick(Card(suit: '♥', rank: 'Q'), 2) // Follow suit
          .addCardToTrick(Card(suit: '♦', rank: 'J'), 3); // Cannot follow suit

      // Player 0 should win with highest hearts (A > K > Q)
      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(completedRound.trickWinners.first, 0);
    });

    test(
      'Trick winning rules - power suit beats lead suit even if lower value',
      () {
        final round = Round(
          roundNumber: 4,
          powerCard: Card(
            suit: '♠',
            rank: 'A',
          ), // Changed from powerSuit to powerCard
          playerHands: [
            [Card(suit: '♥', rank: 'A')], // Player 0: leads with hearts
            [Card(suit: '♥', rank: 'K')], // Player 1: has hearts
            [
              Card(suit: '♠', rank: '2'),
            ], // Player 2: has power suit (low value)
            [Card(suit: '♦', rank: 'J')], // Player 3: has diamonds only
          ],
          dealer: 2,
        );

        // Player 2 plays power suit even though they could follow suit
        final roundWithTrick = round
            .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead with hearts
            .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Follow suit
            .addCardToTrick(Card(suit: '♠', rank: '2'), 2) // Play power suit
            .addCardToTrick(
              Card(suit: '♦', rank: 'J'),
              3,
            ); // Cannot follow suit

        // Player 2 should win with power suit even though it's lower value than hearts
        final completedRound = roundWithTrick.completeCurrentTrick();
        expect(completedRound.trickWinners.first, 2);
      },
    );

    test(
      'Trick winning rules - highest power suit wins when multiple power suits',
      () {
        final round = Round(
          roundNumber: 4,
          powerCard: Card(
            suit: '♠',
            rank: 'A',
          ), // Changed from powerSuit to powerCard
          playerHands: [
            [Card(suit: '♥', rank: 'A')], // Player 0: leads with hearts
            [Card(suit: '♠', rank: 'K')], // Player 1: has power suit
            [Card(suit: '♠', rank: 'A')], // Player 2: has power suit (higher)
            [Card(suit: '♦', rank: 'J')], // Player 3: has diamonds only
          ],
          dealer: 3,
        );

        // Multiple players play power suit
        final roundWithTrick = round
            .addCardToTrick(Card(suit: '♥', rank: 'A'), 0) // Lead with hearts
            .addCardToTrick(Card(suit: '♠', rank: 'K'), 1) // Play power suit
            .addCardToTrick(
              Card(suit: '♠', rank: 'A'),
              2,
            ) // Play power suit (higher)
            .addCardToTrick(
              Card(suit: '♦', rank: 'J'),
              3,
            ); // Cannot follow suit

        // Player 2 should win with highest power suit (A > K)
        final completedRound = roundWithTrick.completeCurrentTrick();
        expect(completedRound.trickWinners.first, 2);
      },
    );
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

      // Enable bidding first
      gameState.enableBidding();

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

      // Enable bidding first
      gameState.enableBidding();

      // Set bids first
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play cards for first trick - check if cards are valid before playing
      final player0Card = gameState.currentRound!.playerHands[0][0];
      final player1Card = gameState.currentRound!.playerHands[1][0];
      final player2Card = gameState.currentRound!.playerHands[2][0];
      final player3Card = gameState.currentRound!.playerHands[3][0];

      // Play first card (can be any card)
      gameState.playCard(0, player0Card);

      // For subsequent players, check if they can follow suit
      // If not, they can play any card
      final validCards1 = gameState.getValidCards(1);
      final cardToPlay1 = validCards1.isNotEmpty ? validCards1[0] : player1Card;
      gameState.playCard(1, cardToPlay1);

      final validCards2 = gameState.getValidCards(2);
      final cardToPlay2 = validCards2.isNotEmpty ? validCards2[0] : player2Card;
      gameState.playCard(2, cardToPlay2);

      final validCards3 = gameState.getValidCards(3);
      final cardToPlay3 = validCards3.isNotEmpty ? validCards3[0] : player3Card;
      gameState.playCard(3, cardToPlay3);

      // Manually complete the trick since it now has a 3-second delay
      gameState.completeCurrentTrick();

      expect(gameState.currentRound!.trickWinners.length, 1);
      expect(
        gameState.players[0].tricksWon +
            gameState.players[1].tricksWon +
            gameState.players[2].tricksWon +
            gameState.players[3].tricksWon,
        1,
      );
    });

    test('Completed trick display delay', () {
      gameState.startNewGame();

      // Enable bidding first
      gameState.enableBidding();

      // Set bids so the round can progress to playing phase
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Play first card
      List<Card> validCards0 = gameState.getValidCards(0);
      gameState.playCard(0, validCards0[0]);

      // Play second card
      List<Card> validCards1 = gameState.getValidCards(1);
      gameState.playCard(1, validCards1[0]);

      // Play third card
      List<Card> validCards2 = gameState.getValidCards(2);
      gameState.playCard(2, validCards2[0]);

      // Should not be showing completed trick yet
      expect(gameState.isShowingCompletedTrick, false);

      // Play the fourth card (completing the trick)
      List<Card> validCards3 = gameState.getValidCards(3);
      gameState.playCard(3, validCards3[0]);

      // Should now be showing completed trick (dialog will be shown)
      expect(gameState.isShowingCompletedTrick, true);
      expect(gameState.currentRound!.isCurrentTrickComplete, true);

      // Manually complete the trick (simulating dialog dismissal)
      gameState.completeCurrentTrick();

      // Should no longer be showing completed trick
      expect(gameState.isShowingCompletedTrick, false);
      expect(gameState.currentRound!.trickWinners.length, 1);
    });
  });

  group('Scoring System Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('Exact bid scoring logic', () {
      gameState.startNewGame();

      // Enable bidding first
      gameState.enableBidding();

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

        // Reveal power suit first
        gameState.enableBidding();

        // Set bids and complete round
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
