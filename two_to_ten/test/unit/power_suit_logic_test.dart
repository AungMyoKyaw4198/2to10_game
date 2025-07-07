import 'package:flutter_test/flutter_test.dart';
import 'package:two_to_ten/models/card.dart';
import 'package:two_to_ten/models/round.dart';
import 'package:two_to_ten/providers/game_state.dart';
import 'package:two_to_ten/constants/game_constants.dart';

void main() {
  group('Power Card Logic Tests', () {
    test('Power card should be the highest card in its suit', () {
      // Test case: King of Spades is power card, so it should be highest in spades
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'K'), // King of Spades is power card
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♠', rank: 'A')], // James: has Ace of Spades
          [Card(suit: '♠', rank: 'K')], // John: has King of Spades (power card)
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      // Play cards in order: Hearts lead, then power suit cards
      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(Card(suit: '♠', rank: 'A'), 1) // Play Ace of Spades
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            2,
          ) // Play King of Spades (power card)
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
        reason:
            'John with King of Spades (power card) should win over James with Ace of Spades',
      );
    });

    test('Power card should beat all other suits regardless of value', () {
      // Test case: 2 of Clubs is power card, should beat even Ace of Hearts
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♣', rank: '2'), // 2 of Clubs is power card
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♣', rank: '2')], // John: has 2 of Clubs (power card)
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
            Card(suit: '♣', rank: '2'),
            2,
          ) // Play 2 of Clubs (power card, lowest value)
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with 2 of Clubs (power card) should win even though it\'s lowest value',
      );
    });

    test('Multiple power suit cards - power card should win', () {
      // Test case: When multiple players play power suit, power card should win
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'Q'), // Queen of Spades is power card
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♠', rank: 'K')], // James: has King of Spades
          [
            Card(suit: '♠', rank: 'Q'),
          ], // John: has Queen of Spades (power card)
          [Card(suit: '♦', rank: 'J')], // Tom: has Jack of Diamonds
        ],
        dealer: 2,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 1) // Play King of Spades
          .addCardToTrick(
            Card(suit: '♠', rank: 'Q'),
            2,
          ) // Play Queen of Spades (power card)
          .addCardToTrick(
            Card(suit: '♦', rank: 'J'),
            3,
          ); // Play Jack of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with Queen of Spades (power card) should win over James with King of Spades',
      );
    });

    test('Power card leads the trick', () {
      // Test case: When power card leads the trick
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'A'), // Ace of Spades is power card
        playerHands: [
          [
            Card(suit: '♠', rank: 'A'),
          ], // Alex: leads with Ace of Spades (power card)
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♠', rank: '2')], // John: has 2 of Spades
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♠', rank: 'A'),
            0,
          ) // Lead with Ace of Spades (power card)
          .addCardToTrick(Card(suit: '♥', rank: 'K'), 1) // Play King of Hearts
          .addCardToTrick(Card(suit: '♠', rank: '2'), 2) // Play 2 of Spades
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        0,
        reason:
            'Alex with Ace of Spades (power card) should win when leading with power card',
      );
    });

    test('Power card leads, multiple power suit cards played', () {
      // Test case: Power card leads, multiple power suit cards played
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'K'), // King of Spades is power card
        playerHands: [
          [
            Card(suit: '♠', rank: 'K'),
          ], // Alex: leads with King of Spades (power card)
          [Card(suit: '♥', rank: 'A')], // James: has Ace of Hearts
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades
          [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
        ],
        dealer: 0,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♠', rank: 'K'),
            0,
          ) // Lead with King of Spades (power card)
          .addCardToTrick(Card(suit: '♥', rank: 'A'), 1) // Play Ace of Hearts
          .addCardToTrick(Card(suit: '♠', rank: 'A'), 2) // Play Ace of Spades
          .addCardToTrick(
            Card(suit: '♦', rank: 'Q'),
            3,
          ); // Play Queen of Diamonds

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        0,
        reason:
            'Alex with King of Spades (power card) should win over John with Ace of Spades',
      );
    });

    test('All players play power suit cards', () {
      // Test case: All players play power suit cards
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'Q'), // Queen of Spades is power card
        playerHands: [
          [Card(suit: '♠', rank: 'K')], // Alex: has King of Spades
          [
            Card(suit: '♠', rank: 'Q'),
          ], // James: has Queen of Spades (power card)
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades
          [Card(suit: '♠', rank: 'J')], // Tom: has Jack of Spades
        ],
        dealer: 1,
      );

      final roundWithTrick = round
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 0) // Play King of Spades
          .addCardToTrick(
            Card(suit: '♠', rank: 'Q'),
            1,
          ) // Play Queen of Spades (power card)
          .addCardToTrick(Card(suit: '♠', rank: 'A'), 2) // Play Ace of Spades
          .addCardToTrick(Card(suit: '♠', rank: 'J'), 3); // Play Jack of Spades

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        1,
        reason:
            'James with Queen of Spades (power card) should win among all power suit cards',
      );
    });

    test(
      'Power card ranking system - lower rank power card beats higher rank',
      () {
        // Test case: 3 of Hearts is power card, should beat Ace of Hearts
        final round = Round(
          roundNumber: 2,
          powerCard: Card(suit: '♥', rank: '3'), // 3 of Hearts is power card
          playerHands: [
            [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
            [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
            [Card(suit: '♥', rank: '3')], // John: has 3 of Hearts (power card)
            [Card(suit: '♦', rank: 'Q')], // Tom: has Queen of Diamonds
          ],
          dealer: 0,
        );

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
              Card(suit: '♥', rank: '3'),
              2,
            ) // Play 3 of Hearts (power card)
            .addCardToTrick(
              Card(suit: '♦', rank: 'Q'),
              3,
            ); // Play Queen of Diamonds

        final completedRound = roundWithTrick.completeCurrentTrick();
        expect(
          completedRound.trickWinners.first,
          2,
          reason:
              'John with 3 of Hearts (power card) should win over Alex with Ace of Hearts',
        );
      },
    );

    test('Complex scenario: Multiple power suits with different values', () {
      // Test case: Complex scenario with multiple power suit cards and different values
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'J'), // Jack of Spades is power card
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♠', rank: 'K')], // James: has King of Spades
          [Card(suit: '♠', rank: 'J')], // John: has Jack of Spades (power card)
          [Card(suit: '♠', rank: 'Q')], // Tom: has Queen of Spades
        ],
        dealer: 3,
      );

      final roundWithTrick = round
          .addCardToTrick(
            Card(suit: '♥', rank: 'A'),
            0,
          ) // Lead with Ace of Hearts
          .addCardToTrick(Card(suit: '♠', rank: 'K'), 1) // Play King of Spades
          .addCardToTrick(
            Card(suit: '♠', rank: 'J'),
            2,
          ) // Play Jack of Spades (power card)
          .addCardToTrick(
            Card(suit: '♠', rank: 'Q'),
            3,
          ); // Play Queen of Spades

      final completedRound = roundWithTrick.completeCurrentTrick();
      expect(
        completedRound.trickWinners.first,
        2,
        reason:
            'John with Jack of Spades (power card) should win among all power suit cards (J > K > Q)',
      );
    });

    test('Step by step power card logic verification', () {
      // Test case: Step by step verification of the power card logic
      final round = Round(
        roundNumber: 2,
        powerCard: Card(suit: '♠', rank: 'A'), // Ace of Spades is power card
        playerHands: [
          [Card(suit: '♥', rank: 'A')], // Alex: leads with Ace of Hearts
          [Card(suit: '♥', rank: 'K')], // James: has King of Hearts
          [Card(suit: '♠', rank: 'A')], // John: has Ace of Spades (power card)
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

      // Step 3: Play Ace of Spades (power card)
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
        reason: 'John with Ace of Spades (power card) should win',
      );
    });
  });
}
