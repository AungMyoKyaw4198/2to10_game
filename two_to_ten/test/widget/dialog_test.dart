import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_to_ten/widgets/trick_winner_dialog.dart';
import 'package:two_to_ten/widgets/round_winner_dialog.dart';
import 'package:two_to_ten/models/player.dart';

void main() {
  group('TrickWinnerDialog Tests', () {
    testWidgets('TrickWinnerDialog displays winner name correctly', (
      WidgetTester tester,
    ) async {
      bool dialogDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => TrickWinnerDialog(
                            winnerName: 'Player 1',
                            onDismiss: () {
                              dialogDismissed = true;
                              Navigator.of(context).pop();
                            },
                          ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Trick Winner!'), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify dialog was dismissed
      expect(dialogDismissed, true);
      expect(find.text('Trick Winner!'), findsNothing);
    });
  });

  group('RoundWinnerDialog Tests', () {
    testWidgets('RoundWinnerDialog displays round results correctly', (
      WidgetTester tester,
    ) async {
      final testPlayers = [
        Player(name: 'Player 1', tricksWon: 3),
        Player(name: 'Player 2', tricksWon: 1),
        Player(name: 'Player 3', tricksWon: 0),
        Player(name: 'Player 4', tricksWon: 2),
      ];

      bool dialogDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => RoundWinnerDialog(
                            roundNumber: 3,
                            players: testPlayers,
                            onDismiss: () {
                              dialogDismissed = true;
                              Navigator.of(context).pop();
                            },
                          ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Round 3 Complete!'), findsOneWidget);
      expect(find.text('Round Winner'), findsOneWidget);
      expect(find.text('3 tricks won'), findsOneWidget);
      expect(find.text('Round Results'), findsOneWidget);
      expect(find.text('Continue to Next Round'), findsOneWidget);

      // Verify all players are shown in results
      for (final player in testPlayers) {
        expect(find.text('Won: ${player.tricksWon}'), findsOneWidget);
      }

      // Verify the winner is shown (Player 1 with 3 tricks)
      expect(find.text('Player 1'), findsAtLeastNWidgets(1));

      // Tap continue button
      await tester.tap(find.text('Continue to Next Round'));
      await tester.pumpAndSettle();

      // Verify dialog was dismissed
      expect(dialogDismissed, true);
      expect(find.text('Round 3 Complete!'), findsNothing);
    });
  });
}
