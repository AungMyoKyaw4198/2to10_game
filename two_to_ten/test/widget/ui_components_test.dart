import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:two_to_ten/providers/game_state.dart';
import 'package:two_to_ten/widgets/player_box.dart';
import 'package:two_to_ten/widgets/bid_input_widget.dart';
import 'package:two_to_ten/screens/game_screen.dart';
import 'package:two_to_ten/models/player.dart';
import 'package:two_to_ten/models/round.dart';
import 'package:two_to_ten/models/card.dart'
    as game_card; // Added prefix to avoid naming conflict
import 'package:two_to_ten/constants/game_constants.dart';

void main() {
  group('PlayerBox Widget Tests', () {
    late Player testPlayer;
    late Round testRound;

    setUp(() {
      testPlayer = Player(
        name: 'Test Player',
        score: 50,
        bags: 3,
        currentBid: 2,
        tricksWon: 2,
      );

      testRound = Round(
        roundNumber: 2,
        powerCard: game_card.Card(
          suit: '♠',
          rank: 'A',
        ), // Changed from powerSuit to powerCard
        playerHands: List.generate(4, (_) => []),
        dealer: 0,
      );
    });

    testWidgets('PlayerBox displays player information correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerBox(
              player: testPlayer,
              position: 'top',
              playerIndex: 0,
              currentRound: testRound,
              onCardPlayed: (card) {},
              gameState: gameState,
            ),
          ),
        ),
      );

      // Verify player name is displayed
      expect(find.text('Test Player'), findsOneWidget);

      // Verify score is displayed - for player index 0, it shows " | Score: 50"
      expect(find.textContaining('Score: 50'), findsOneWidget);

      // Verify bid is displayed
      expect(find.textContaining('Bid: 2'), findsOneWidget);

      // Verify bags are displayed
      expect(find.textContaining('Bags: 3'), findsOneWidget);
    });

    testWidgets('PlayerBox shows bag warning when bags >= 4', (
      WidgetTester tester,
    ) async {
      final playerWithWarning = testPlayer.copyWith(bags: 4);
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerBox(
              player: playerWithWarning,
              position: 'bottom',
              playerIndex: 1,
              currentRound: testRound,
              onCardPlayed: (card) {},
              gameState: gameState,
            ),
          ),
        ),
      );

      // Should show bag warning indicator
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('PlayerBox shows turn indicator when it is player turn', (
      WidgetTester tester,
    ) async {
      final gameState = GameState();
      gameState.startNewGame();

      // Set bids so the round can progress to playing phase
      for (int i = 0; i < 4; i++) {
        gameState.setPlayerBid(i, 1);
      }

      // Set up round where player 0 is current turn (first to play)
      final roundWithTurn = gameState.currentRound!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerBox(
              player: testPlayer,
              position: 'left',
              playerIndex: 0,
              currentRound: roundWithTurn,
              onCardPlayed: (card) {},
              gameState: gameState,
            ),
          ),
        ),
      );

      // Should show turn indicator for first player
      expect(find.text('YOUR TURN'), findsOneWidget);
    });
  });

  group('BidInputWidget Tests', () {
    late GameState gameState;
    late Round testRound;

    setUp(() {
      gameState = GameState();
      gameState.startNewGame();
      testRound = gameState.currentRound!;
    });

    testWidgets('BidInputWidget shows dialog for bidding', (
      WidgetTester tester,
    ) async {
      // Enable bidding first
      gameState.enableBidding();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: Scaffold(
              body: BidInputWidget(
                currentRound: testRound,
                onBidSubmitted: (playerIndex, bid) {},
              ),
            ),
          ),
        ),
      );

      // Should show bid dialog
      await tester.pumpAndSettle();
      expect(find.text('Alex - Enter your bid'), findsOneWidget);

      // Should show bid range
      expect(find.text('Bid range: 0 - 2'), findsOneWidget);
    });

    testWidgets('BidInputWidget allows bid selection', (
      WidgetTester tester,
    ) async {
      // Enable bidding first
      gameState.enableBidding();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: Scaffold(
              body: BidInputWidget(
                currentRound: testRound,
                onBidSubmitted: (playerIndex, bid) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show bid selection controls
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Initial bid value
    });
  });

  group('GameScreen Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    testWidgets('GameScreen shows start game button initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const GameScreen(),
          ),
        ),
      );

      expect(find.text('Start New Game'), findsOneWidget);
    });

    testWidgets('GameScreen starts game when start button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const GameScreen(),
          ),
        ),
      );

      // Tap start game button
      await tester.tap(find.text('Start New Game'));
      await tester.pumpAndSettle();

      expect(gameState.isGameStarted, true);
      expect(find.text('Round 2'), findsOneWidget);
    });

    testWidgets('GameScreen shows all 4 player boxes', (
      WidgetTester tester,
    ) async {
      gameState.startNewGame();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const GameScreen(),
          ),
        ),
      );

      // Should show all 4 player names
      for (String name in GameConstants.defaultPlayerNames) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('GameScreen shows Start Round button before bidding enabled', (
      WidgetTester tester,
    ) async {
      gameState.startNewGame();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const GameScreen(),
          ),
        ),
      );

      // Should show Start Round button initially
      expect(find.text('Start Round'), findsOneWidget);

      // Should show power card immediately
      expect(find.textContaining('Power Card'), findsOneWidget);

      // Tap Start Round button
      await tester.tap(find.text('Start Round'));
      await tester.pumpAndSettle();

      // Should still show power card
      expect(find.textContaining('Power Card'), findsOneWidget);

      // Should show bid dialog after bidding is enabled
      expect(find.text('Alex - Enter your bid'), findsOneWidget);
    });

    testWidgets('GameScreen handles 10-card round overflow', (
      WidgetTester tester,
    ) async {
      gameState.startNewGame();

      // Play through rounds to get to round 10
      for (int round = 2; round <= 10; round++) {
        // Enable bidding for this round
        gameState.enableBidding();

        // Set bids for this round
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }

        // Complete the round
        gameState.completeRound();
        // Note: Round completion now happens automatically after a 2-second delay
        // The dialog is no longer shown, but the callback still triggers startNextRound()
        gameState.startNextRound();
      }

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const GameScreen(),
          ),
        ),
      );

      // Should not crash with 10 cards
      expect(find.text('Game Complete!'), findsOneWidget);
    });

    testWidgets(
      'GameScreen does not show trick/round winner dialogs automatically',
      (WidgetTester tester) async {
        gameState.startNewGame();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<GameState>.value(
              value: gameState,
              child: const GameScreen(),
            ),
          ),
        );

        // Enable bidding and set bids
        gameState.enableBidding();
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }

        // Play all tricks for round 2
        for (int trick = 0; trick < 2; trick++) {
          // Play all 4 cards for this trick
          for (int player = 0; player < 4; player++) {
            if (gameState.currentRound!.playerHands[player].isNotEmpty) {
              final validCards = gameState.getValidCards(player);
              if (validCards.isNotEmpty) {
                final card = validCards[0];
                gameState.playCard(player, card);
              }
            }
          }
          // Now the trick is complete, we can complete it
          gameState.completeCurrentTrick();

          // Handle the timer from Future.delayed
          await tester.pump(const Duration(seconds: 3));
        }

        // Complete the round
        gameState.completeRound();
        gameState.startNextRound();

        // Handle the timer from Future.delayed
        await tester.pump(const Duration(seconds: 3));

        // Verify we moved to the next round without showing dialogs
        // Note: The actual round number depends on the game logic, but it should have progressed
        expect(gameState.currentRoundNumber, greaterThan(2));

        // The dialogs should not be present in the widget tree
        expect(find.text('Trick Winner!'), findsNothing);
        expect(find.text('Round Complete!'), findsNothing);
      },
    );
  });

  group('Edge Case UI Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    testWidgets('BidInputWidget handles zero bid correctly', (
      WidgetTester tester,
    ) async {
      gameState.startNewGame();
      // Enable bidding first
      gameState.enableBidding();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: Scaffold(
              body: BidInputWidget(
                currentRound: gameState.currentRound!,
                onBidSubmitted: (playerIndex, bid) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 0 as a valid bid option
      expect(find.text('0'), findsOneWidget);

      // Should not crash
      expect(find.text('Bid range: 0 - 2'), findsOneWidget);
    });

    testWidgets(
      'GameScreen handles automatic progression without user interaction',
      (WidgetTester tester) async {
        gameState.startNewGame();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<GameState>.value(
              value: gameState,
              child: const GameScreen(),
            ),
          ),
        );

        // Enable bidding and set bids
        gameState.enableBidding();
        for (int i = 0; i < 4; i++) {
          gameState.setPlayerBid(i, 1);
        }

        // Play all tricks for round 2
        for (int trick = 0; trick < 2; trick++) {
          // Play all 4 cards for this trick
          for (int player = 0; player < 4; player++) {
            if (gameState.currentRound!.playerHands[player].isNotEmpty) {
              final validCards = gameState.getValidCards(player);
              if (validCards.isNotEmpty) {
                final card = validCards[0];
                gameState.playCard(player, card);
              }
            }
          }
          // Now the trick is complete, we can complete it
          gameState.completeCurrentTrick();

          // Handle the timer from Future.delayed
          await tester.pump(const Duration(seconds: 3));
        }

        // Complete the round
        gameState.completeRound();
        gameState.startNextRound();

        // Handle the timer from Future.delayed
        await tester.pump(const Duration(seconds: 3));

        // Verify we moved to the next round automatically
        // Note: The actual round number depends on the game logic, but it should have progressed
        expect(gameState.currentRoundNumber, greaterThan(2));

        // Verify the UI updates correctly - look for the specific round number text
        await tester.pumpAndSettle();
        expect(
          find.text('Round ${gameState.currentRoundNumber}'),
          findsOneWidget,
        );
      },
    );
  });
}
