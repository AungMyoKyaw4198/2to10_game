import 'package:flutter_test/flutter_test.dart';
import 'package:two_to_ten/models/card.dart';
import 'package:two_to_ten/models/round.dart';
import 'package:two_to_ten/providers/game_state.dart';

void main() {
  group('Power Suit Logic Tests - Client Issue Investigation', () {
    test('CRITICAL: Dynamic player order - Tom wins and starts next trick', () {
      // Test the specific scenario mentioned: Tom wins first trick, then starts second trick
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [
            Card(suit: '♥', rank: 'A'),
            Card(suit: '♥', rank: 'A'),
          ], // Alex: has Ace of Hearts for both tricks
          [
            Card(suit: '♥', rank: 'K'),
            Card(suit: '♦', rank: 'J'),
          ], // James: has King of Hearts, then Jack of Diamonds
          [
            Card(suit: '♦', rank: 'Q'),
            Card(suit: '♣', rank: '10'),
          ], // John: has Queen of Diamonds, then 10 of Clubs
          [
            Card(suit: '♠', rank: 'A'),
            Card(suit: '♠', rank: 'K'),
          ], // Tom: has Ace of Spades, then King of Spades
        ],
        dealer: 0,
      );

      // First trick: Dealer (Alex) leads, Tom wins with power suit
      var currentRound = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Alex leads with Ace of Hearts
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // James follows suit
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            2,
          ) // John plays different suit
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            3,
          ); // Tom plays power suit

      // Verify Tom wins the first trick
      final firstTrickWinner = currentRound.determineTrickWinner();
      expect(
        firstTrickWinner,
        3,
        reason: 'Tom should win with Ace of Spades (power suit)',
      );

      // Complete first trick
      currentRound = currentRound.completeCurrentTrick();
      expect(currentRound.trickWinners.length, 1);
      expect(currentRound.trickWinners.last, 3);

      // Second trick: Tom should start (as winner of previous trick)
      expect(
        currentRound.firstPlayer,
        3,
        reason: 'Tom should start second trick',
      );

      // Add cards for second trick (Tom leads)
      currentRound = currentRound
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            3,
          ) // Tom leads with King of Spades
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Alex plays different suit
          .addCardToTrick(
            Card(suit: '♦', rank: 'J'),
            1,
          ) // James plays different suit
          .addCardToTrick(
            Card(suit: '♣', rank: '10'),
            2,
          ); // John plays different suit

      // Verify Tom wins second trick (power suit leads)
      final secondTrickWinner = currentRound.determineTrickWinner();
      expect(
        secondTrickWinner,
        3,
        reason: 'Tom should win second trick with power suit lead',
      );

      // Complete second trick
      currentRound = currentRound.completeCurrentTrick();
      expect(currentRound.trickWinners.length, 2);
      expect(currentRound.trickWinners.last, 3);
    });

    test(
      'Ace of Spades (power suit) should always win when Spades is power suit',
      () {
        // Test case: Spades is power suit, Ace of Spades should win
        final round = Round(
          roundNumber: 2,
          powerSuit: '♠', // Spades is power suit
          playerHands: [
            [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
            [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
            [
              Card(suit: '♠', rank: 'A'),
            ], // John: has Ace of Spades (power suit)
            [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
          ],
          dealer: 0,
        );

        // Play cards in order: Hearts lead, then power suit, then others
        final roundWithTrick = round
            .addCardToTrick(
              Card(suit: '♥', rank: 'A'),
              0,
            ) // Lead with Ace of Hearts
            .addCardToTrick(
              Card(suit: '♥', rank: 'K'),
              1,
            ) // Follow suit with King of Hearts
            .addCardToTrick(
              Card(suit: '♠', rank: 'A'),
              2,
            ) // Play Ace of Spades (power suit)
            .addCardToTrick(
              Card(suit: '♦', rank: 'Q'),
              3,
            ); // Play Queen of Diamonds

        expect(roundWithTrick.isCurrentTrickComplete, true);

        final completedRound = roundWithTrick.completeCurrentTrick();
        expect(completedRound.trickWinners.length, 1);
        expect(
          completedRound.trickWinners.first,
          2,
          reason: 'John with Ace of Spades (power suit) should win',
        );
      },
    );

    test('Power suit should win regardless of lead suit value', () {
      // Test case: Power suit should beat even the highest lead suit
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [
            Card(suit: '♠', rank: '2'),
          ], // John: has 2 of Spades (power suit, lowest value)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 1,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts (highest)
          .addCardToTrick(
            Card(suit: '♥', rank: 'K'),
            1,
          ) // Follow suit with King of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: '2'),
            2,
          ) // Play 2 of Spades (power suit, lowest)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with 2 of Spades (power suit) should win even though it\'s lowest value',
      );
    });

    test('Multiple power suit cards - highest power suit should win', () {
      // Test case: When multiple players play power suit, highest should win
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [
            Card(suit: '♠', rank: 'K'),
          ], // James: has King of Spades (power suit)
          [
            Card(suit: '♠', rank: 'A'),
          ], // John: has Ace of Spades (power suit, higher)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 2,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            1,
          ) // Play King of Spades (power suit)
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            2,
          ) // Play Ace of Spades (power suit, higher)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with Ace of Spades should win over James with King of Spades',
      );
    });

    test('Power suit leads the trick - should still win', () {
      // Test case: When power suit leads the trick
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [
            Card(suit: '♠', rank: 'A'),
          ], // Alex: leads with Ace of Spades (power suit)
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♠', rank: '2')], // John: has 2 of Spades (power suit)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            0,
          ) // Lead with Ace of Spades (power suit)
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Play King of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: '2'),
            2,
          ) // Play 2 of Spades (power suit)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        0,
        reason:
            'Alex with Ace of Spades should win when leading with power suit',
      );
    });

    test('Power suit vs power suit when power suit leads', () {
      // Test case: Power suit leads, multiple power suits played
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [
            Card(suit: '♠', rank: 'K'),
          ], // Alex: leads with King of Spades (power suit)
          [Card(suit: '♥', rank: 'A')], // James: has Ace of Hearts
          [
            Card(suit: '♠', rank: 'A'),
          ], // John: has Ace of Spades (power suit, higher)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            0,
          ) // Lead with King of Spades (power suit)
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 1) // Play Ace of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            2,
          ) // Play Ace of Spades (power suit, higher)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with Ace of Spades should win over Alex with King of Spades',
      );
    });

    test('Edge case: All players play power suit', () {
      // Test case: All players play power suit cards
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♠', rank: 'K')], // Alex: has King of Spades
          [Card(suit: '♠', rank: 'Q')], // James: has Queen of Spades
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades (highest)
          [Card(suit: '♠', rank: 'J')], // Tom: has Jack of Spades
        ],
        dealer: 1,
      );

      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 0) // Play King of Spades
          .addCardToTrick(Card(suit: '♠', rank: 'Q'), 1) // Play Queen of Spades
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            2,
          ) // Play Ace of Spades (highest)
          .addCardToTrick(Card(suit: '♠', rank: 'J'), 3); // Play Jack of Spades

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason: 'John with Ace of Spades should win among all power suit cards',
      );
    });

    test(
      'Edge case: Power suit vs high lead suit when power suit is lower value',
      () {
        // Test case: Power suit with lower value should still beat high lead suit
        final round = Round(
          roundNumber: 2,
          powerSuit: '♠', // Spades is power suit
          playerHands: [
            [
              Card(suit: '♥', rank: 'A'),
            ], // Alex: leads with Ace of Hearts (highest value)
            [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
            [
              Card(suit: '♠', rank: '2'),
            ], // John: has 2 of Spades (power suit, lowest value)
            [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
          ],
          dealer: 0,
        );

        final roundWithTrick = round
            .addCardToTrick(
              Card(suit: '♥', rank: 'A'),
              0,
            ) // Lead with Ace of Hearts (highest)
            .addCardToTrick(
              Card(suit: '♥', rank: 'K'),
              1,
            ) // Follow suit with King of Hearts
            .addCardToTrick(
              Card(suit: '♠', rank: '2'),
              2,
            ) // Play 2 of Spades (power suit, lowest)
            .addCardToTrick(
              Card(suit: '♦', rank: 'Q'),
              3,
            ); // Play Queen of Diamonds

        final completedRound = roundWithTrick.completeCurrentTrick();
        expect(
          completedRound.trickWinners.first,
          2,
          reason:
              'John with 2 of Spades (power suit) should win over Ace of Hearts',
        );
      },
    );

    test('Verify card values are correct for comparison', () {
      // Test case: Verify that card values are being compared correctly
      final aceSpades = Card(suit: '♠', rank: 'A');
      final kingSpades = Card(suit: '♠', rank: 'K');
      final queenSpades = Card(suit: '♠', rank: 'Q');
      final jackSpades = Card(suit: '♠', rank: 'J');
      final tenSpades = Card(suit: '♠', rank: '10');
      final twoSpades = Card(suit: '♠', rank: '2');

      expect(aceSpades.value, 14);
      expect(kingSpades.value, 13);
      expect(queenSpades.value, 12);
      expect(jackSpades.value, 11);
      expect(tenSpades.value, 10);
      expect(twoSpades.value, 2);

      // Verify comparison works correctly
      expect(aceSpades.value > kingSpades.value, true);
      expect(kingSpades.value > queenSpades.value, true);
      expect(queenSpades.value > jackSpades.value, true);
      expect(jackSpades.value > tenSpades.value, true);
      expect(tenSpades.value > twoSpades.value, true);
    });

    test('Complex scenario: Multiple power suits with different values', () {
      // Test case: Complex scenario with multiple power suits and different values
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [
            Card(suit: '♠', rank: 'K'),
          ], // James: has King of Spades (power suit)
          [
            Card(suit: '♠', rank: 'A'),
          ], // John: has Ace of Spades (power suit, highest)
          [Card(suit: '♠', rank: 'Q')], // Tom: has Queen of Spades (power suit)
        ],
        dealer: 3,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            1,
          ) // Play King of Spades (power suit)
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            2,
          ) // Play Ace of Spades (power suit, highest)
          .addCardToTrick(
            Card(suit: '♠', rank: 'Q'),
            3,
          ); // Play Queen of Spades (power suit)

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with Ace of Spades should win among all power suit cards (A > K > Q)',
      );
    });

    test('Verify trick winner determination logic step by step', () {
      // Test case: Step by step verification of the trick winner logic
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades (power suit)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      // Step 1: Lead with Ace of Hearts
      var currentRound = round.addCardToTrick(Card(suit: '♥', rank: 'A'), 0);
      expect(currentRound.currentTrick.length, 1);
      expect(currentRound.currentTrick[0].suit, '♥');
      expect(currentRound.currentTrick[0].rank, 'A');

      // Step 2: Follow suit with King of Hearts
      currentRound = currentRound.addCardToTrick(Card(suit: '♥', rank: 'K'), 1);
      expect(currentRound.currentTrick.length, 2);
      expect(currentRound.currentTrick[1].suit, '♥');
      expect(currentRound.currentTrick[1].rank, 'K');

      // Step 3: Play Ace of Spades (power suit)
      currentRound = currentRound.addCardToTrick(Card(suit: '♠', rank: 'A'), 2);
      expect(currentRound.currentTrick.length, 3);
      expect(currentRound.currentTrick[2].suit, '♠');
      expect(currentRound.currentTrick[2].rank, 'A');

      // Step 4: Play Queen of Diamonds
      currentRound = currentRound.addCardToTrick(Card(suit: '♦', rank: 'Q'), 3);
      expect(currentRound.currentTrick.length, 4);
      expect(currentRound.isCurrentTrickComplete, true);

      // Step 5: Complete trick and verify winner
      final completedRound = currentRound.completeCurrentTrick();
      expect(completedRound.trickWinners.length, 1);
      expect(
        completedRound.trickWinners.first,
        2,
        reason: 'John with Ace of Spades (power suit) should win',
      );
    });

    test('CRITICAL: Compare Round vs GameState trick winner logic', () {
      // This test compares the two different implementations of trick winner logic
      // to identify if they produce different results

      final round = Round(
        roundNumber: 2,
        powerSuit: '♠', // Spades is power suit
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades (power suit)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      // Add cards to trick
      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(
            Card(suit: '♥', rank: 'K'),
            1,
          ) // Follow suit with King of Hearts
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            2,
          ) // Play Ace of Spades (power suit)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      // Method 1: Use Round's completeCurrentTrick() method
      final completedRound = roundWithTrick.completeCurrentTrick();
      final roundWinnerIndex = completedRound.trickWinners.last;

      // Method 2: Use Round's determineTrickWinner() method directly
      final directWinnerIndex = roundWithTrick.determineTrickWinner();

      // These should be identical!
      expect(
        roundWinnerIndex,
        directWinnerIndex,
        reason:
            'Round completeCurrentTrick and determineTrickWinner should produce identical results',
      );

      print('Round winner index: $roundWinnerIndex');
      print('Direct winner index: $directWinnerIndex');
    });

    test('CRITICAL: Test multiple scenarios for logic consistency', () {
      // Test multiple scenarios to ensure both implementations are consistent
      final testScenarios = [
        {
          'name': 'Power suit vs lead suit',
          'powerSuit': '♠',
          'cards': [
            Card(suit: '♥', rank: 'A'), // Alex: leads with Ace of Hearts
            Card(suit: '♥', rank: 'K'), // James: has King of Hearts
            Card(suit: '♠', rank: '2'), // John: has 2 of Spades (power suit)
            Card(suit: '♦', rank: 'Q'), // Tom: has Queen of Diamonds
          ],
          'players': [0, 1, 2, 3], // Player indices
          'expectedWinner': 2, // Power suit should win
        },
        {
          'name': 'Multiple power suits',
          'powerSuit': '♠',
          'cards': [
            Card(suit: '♥', rank: 'A'), // Alex: leads with Ace of Hearts
            Card(
              suit: '♠',
              rank: 'K',
            ), // James: has King of Spades (power suit)
            Card(
              suit: '♠',
              rank: 'A',
            ), // John: has Ace of Spades (power suit, higher)
            Card(suit: '♦', rank: 'Q'), // Tom: has Queen of Diamonds
          ],
          'players': [0, 1, 2, 3], // Player indices
          'expectedWinner': 2, // Higher power suit should win
        },
        {
          'name': 'Power suit leads',
          'powerSuit': '♠',
          'cards': [
            Card(
              suit: '♠',
              rank: 'K',
            ), // Alex: leads with King of Spades (power suit)
            Card(suit: '♥', rank: 'A'), // James: has Ace of Hearts
            Card(
              suit: '♠',
              rank: 'A',
            ), // John: has Ace of Spades (power suit, higher)
            Card(suit: '♦', rank: 'Q'), // Tom: has Queen of Diamonds
          ],
          'players': [0, 1, 2, 3], // Player indices
          'expectedWinner': 2, // Higher power suit should win
        },
        {
          'name': 'Tom wins and starts next trick',
          'powerSuit': '♠',
          'cards': [
            Card(suit: '♥', rank: 'A'), // Alex: leads with Ace of Hearts
            Card(suit: '♥', rank: 'K'), // James: follows suit
            Card(suit: '♦', rank: 'Q'), // John: plays different suit
            Card(suit: '♠', rank: 'A'), // Tom: plays power suit
          ],
          'players': [0, 1, 2, 3], // Player indices
          'expectedWinner': 3, // Power suit should win
        },
      ];

      for (final scenario in testScenarios) {
        final cards = scenario['cards'] as List<Card>;
        final players = scenario['players'] as List<int>;

        // Create player hands with the cards that will be played
        final playerHands = [
          [cards[0]], // Alex has the first card
          [cards[1]], // James has the second card
          [cards[2]], // John has the third card
          [cards[3]], // Tom has the fourth card
        ];

        final round = Round(
          roundNumber: 2,
          powerSuit: scenario['powerSuit'] as String,
          playerHands: playerHands,
          dealer: 0,
        );

        // Add cards to trick
        var currentRound = round;
        for (int i = 0; i < 4; i++) {
          currentRound = currentRound.addCardToTrick(cards[i], players[i]);
        }

        // Method 1: Use Round's completeCurrentTrick() method
        final completedRound = currentRound.completeCurrentTrick();
        final roundWinnerIndex = completedRound.trickWinners.last;

        // Method 2: Use Round's determineTrickWinner() method directly
        final directWinnerIndex = currentRound.determineTrickWinner();

        // Both should match expected winner
        expect(
          roundWinnerIndex,
          scenario['expectedWinner'],
          reason: 'Round logic failed for scenario: ${scenario['name']}',
        );
        expect(
          directWinnerIndex,
          scenario['expectedWinner'],
          reason: 'Direct logic failed for scenario: ${scenario['name']}',
        );

        // Both should be identical
        expect(
          roundWinnerIndex,
          directWinnerIndex,
          reason: 'Logic mismatch for scenario: ${scenario['name']}',
        );

        print(
          'Scenario: ${scenario['name']} - Round: $roundWinnerIndex, Direct: $directWinnerIndex',
        );
      }
    });

    test('Verify first player logic for multiple tricks', () {
      final round = Round(
        roundNumber: 2,
        powerSuit: '♠',
        playerHands: List.generate(4, (_) => []),
        dealer: 1, // James is dealer
      );

      // First trick: Dealer (James) should start
      expect(round.firstPlayer, 1, reason: 'Dealer should start first trick');

      // Simulate Tom winning first trick
      var currentRound = round.copyWith(
        trickWinners: [3], // Tom won first trick
      );

      // Second trick: Tom should start (winner of previous trick)
      expect(
        currentRound.firstPlayer,
        3,
        reason: 'Winner of previous trick should start',
      );

      // Simulate Alex winning second trick
      currentRound = currentRound.copyWith(
        trickWinners: [3, 0], // Alex won second trick
      );

      // Third trick: Alex should start
      expect(
        currentRound.firstPlayer,
        0,
        reason: 'Winner of previous trick should start',
      );
    });
  });
}
