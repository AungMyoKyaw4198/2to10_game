import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_state.dart';
import '../models/player.dart';
import '../widgets/player_box.dart';
import '../widgets/bid_input_widget.dart';
import '../widgets/trick_winner_dialog.dart';
import '../widgets/round_winner_dialog.dart';
import '../constants/game_constants.dart';
import '../widgets/playing_card_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up dialog callbacks
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.onTrickComplete = _showTrickWinnerDialog;
    gameState.onRoundComplete = _showRoundWinnerDialog;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showTrickWinnerDialog(String winnerName) {
    Future.delayed(const Duration(seconds: 2), () {
      // Complete the trick after dialog is dismissed
      final gameState = Provider.of<GameState>(context, listen: false);
      gameState.completeCurrentTrick();
    });
    // Hide Trick Winner Dialog for now
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder:
    //       (context) => TrickWinnerDialog(
    //         winnerName: winnerName,
    //         onDismiss: () {
    //           Navigator.of(context).pop();
    //           // Complete the trick after dialog is dismissed
    //           final gameState = Provider.of<GameState>(context, listen: false);
    //           gameState.completeCurrentTrick();
    //         },
    //       ),
    // );
  }

  void _showRoundWinnerDialog(int roundNumber, List<Player> players) {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.startNextRound();
    // Hide Round Winner Dialog for now
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder:
    //       (context) => RoundWinnerDialog(
    //         roundNumber: roundNumber,
    //         players: players,
    //         onDismiss: () {
    //           Navigator.of(context).pop();
    //           // Start the next round after dialog is dismissed
    //           final gameState = Provider.of<GameState>(context, listen: false);
    //           gameState.startNextRound();
    //         },
    //       ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(GameConstants.greenFeltColor),

      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (!gameState.isGameStarted) {
            return _buildStartScreen(context, gameState);
          }

          if (gameState.isGameComplete) {
            return _buildGameCompleteScreen(context, gameState);
          }

          return _buildGameLayout(context, gameState);
        },
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context, GameState gameState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '2 to 10',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Card Game',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => gameState.startNewGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(GameConstants.greenFeltColor),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Start New Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () => _showGameCompletePreview(context),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.orange,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          //   ),
          //   child: const Text(
          //     'Preview Summary Screen',
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildGameLayout(BuildContext context, GameState gameState) {
    return SafeArea(
      child: Column(
        children: [
          // Top player
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlayerBox(
                player: gameState.players[0],
                position: 'top',
                playerIndex: 0,
                currentRound: gameState.currentRound,
                onCardPlayed: (card) => gameState.playCard(0, card),
                gameState: gameState,
              ),
            ),
          ),

          // Middle section with left and right players
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Left player (now player 3)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlayerBox(
                      player: gameState.players[3],
                      position: 'left',
                      playerIndex: 3,
                      currentRound: gameState.currentRound,
                      onCardPlayed: (card) => gameState.playCard(3, card),
                      gameState: gameState,
                    ),
                  ),
                ),

                // Center game area
                Expanded(
                  flex: 2,
                  child: _buildCenterGameArea(context, gameState),
                ),

                // Right player (now player 1)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlayerBox(
                      player: gameState.players[1],
                      position: 'right',
                      playerIndex: 1,
                      currentRound: gameState.currentRound,
                      onCardPlayed: (card) => gameState.playCard(1, card),
                      gameState: gameState,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom player (now player 2)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlayerBox(
                player: gameState.players[2],
                position: 'bottom',
                playerIndex: 2,
                currentRound: gameState.currentRound,
                onCardPlayed: (card) => gameState.playCard(2, card),
                gameState: gameState,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterGameArea(BuildContext context, GameState gameState) {
    return Container(
      // margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        // color: Colors.white.withValues(alpha: 0.1),
        color: Color(0xFF1A5D32),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Color(0xff8b6914), width: 5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Power card display at the top
          if (gameState.currentRound != null) ...[
            Container(
              padding: const EdgeInsets.all(4.0), // Reduced from 8.0
              child: Column(
                children: [
                  Text(
                    'Power Card',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 10, // Reduced from 12
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 4
                  PlayingCardWidget(
                    card: gameState.currentRound!.powerCard,
                    faceUp: true,
                    width: 40,
                    height: 56,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4), // Reduced from 8
          ],

          // Current trick display in the center
          if (gameState.currentRound != null &&
              gameState.currentRound!.currentTrick.isNotEmpty) ...[
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(4.0), // Reduced from 8.0
                child: Column(
                  children: [
                    Text(
                      'Current Trick',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 10, // Reduced from 12
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    SizedBox(
                      height: 140, // Reduced from 120
                      child: Column(
                        children: [
                          // First row (cards 0 and 1)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Card 0 (top-left)
                                _buildTrickCard(gameState, 0),
                                // Card 1 (top-right)
                                _buildTrickCard(gameState, 1),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Second row (cards 2 and 3)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Card 2 (bottom-left)
                                _buildTrickCard(gameState, 2),
                                // Card 3 (bottom-right)
                                _buildTrickCard(gameState, 3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4), // Reduced from 8
          ],

          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Round info
                Text(
                  'Round ${gameState.currentRoundNumber}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Reduced from default
                  ),
                ),

                const SizedBox(height: 4), // Reduced from 8
                // Dealer info
                Text(
                  'Dealer: ${GameConstants.defaultPlayerNames[gameState.currentDealer]}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 12, // Reduced from 14
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8), // Reduced from 16
          // Game controls
          if (!gameState.isBiddingEnabled) ...[
            // Show "Start Round" button to enable bidding
            ElevatedButton(
              onPressed: () => gameState.enableBidding(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(GameConstants.greenFeltColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ), // Reduced padding
              ),
              child: const Text('Start Round'),
            ),
          ] else if (!gameState.currentRound!.allBidsPlaced) ...[
            // Show bid input after bidding is enabled
            BidInputWidget(
              currentRound: gameState.currentRound!,
              onBidSubmitted:
                  (playerIndex, bid) =>
                      gameState.setPlayerBid(playerIndex, bid),
            ),
          ] else if (gameState.currentRound!.areAllTricksComplete) ...[
            ElevatedButton(
              onPressed: () => gameState.completeRound(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(GameConstants.greenFeltColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ), // Reduced padding
              ),
              child: const Text('Complete Round'),
            ),
          ] else ...[
            Text(
              'Playing tricks...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
                fontSize: 14, // Reduced from default
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrickCard(GameState gameState, int cardIndex) {
    if (cardIndex >= gameState.currentRound!.currentTrick.length) {
      // Show empty space for cards not yet played
      return Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white54, size: 20),
        ),
      );
    }

    final card = gameState.currentRound!.currentTrick[cardIndex];
    final playerIndex = gameState.currentRound!.currentTrickPlayers[cardIndex];
    final playerName = GameConstants.defaultPlayerNames[playerIndex];

    return PlayingCardWidget(
      card: card,
      faceUp: true,
      width: 40,
      height: 56,
      playerName: playerName,
    );
  }

  Widget _buildGameCompleteScreen(BuildContext context, GameState gameState) {
    // Trigger confetti when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
      }
    });

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Game Complete!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Winner: ${gameState.getWinner().name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Final scores
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children:
                      _getRankedPlayers(gameState.players).asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final player = entry.value;
                        final rank = index + 1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Rank indicator
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      color:
                                          rank == 1
                                              ? Colors.yellow
                                              : Colors.white,
                                      fontWeight:
                                          rank == 1 ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Score: ${player.score}',
                                style: TextStyle(
                                  color:
                                      rank == 1 ? Colors.yellow : Colors.white,
                                  fontWeight:
                                      rank == 1 ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => gameState.startNewGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(GameConstants.greenFeltColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Confetti effect
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Straight down
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

  void _showGameCompletePreview(BuildContext context) {
    // Show the preview screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Color(GameConstants.greenFeltColor),
              body: _buildGameCompletePreviewScreen(context),
            ),
      ),
    );
  }

  Widget _buildGameCompletePreviewScreen(BuildContext context) {
    // Trigger confetti when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
      }
    });

    // Create dummy player data
    final dummyPlayers = [
      Player(
        name: 'Alex',
        score: 85,
        bags: 2,
        currentBid: 3,
        tricksWon: 3,
        perfectRounds: [
          true,
          true,
          false,
          true,
          false,
          true,
          true,
          false,
          true,
        ],
        immaculateRounds: [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
      ),
      Player(
        name: 'James',
        score: 120,
        bags: 0,
        currentBid: 4,
        tricksWon: 4,
        perfectRounds: [true, true, true, true, true, true, true, true, true],
        immaculateRounds: [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
      ),
      Player(
        name: 'John',
        score: 45,
        bags: 7,
        currentBid: 2,
        tricksWon: 2,
        perfectRounds: [
          false,
          false,
          true,
          false,
          false,
          false,
          true,
          false,
          false,
        ],
        immaculateRounds: [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
      ),
      Player(
        name: 'Tom',
        score: 95,
        bags: 1,
        currentBid: 5,
        tricksWon: 5,
        perfectRounds: [true, false, true, true, true, false, true, true, true],
        immaculateRounds: [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
      ),
    ];

    // Find the winner (Player 2 with highest score)
    final winner = dummyPlayers.reduce((a, b) => a.score > b.score ? a : b);

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Game Complete!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Winner: ${winner.name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Final scores
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children:
                      _getRankedPlayers(dummyPlayers).asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final player = entry.value;
                        final rank = index + 1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Rank indicator
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      color:
                                          rank == 1
                                              ? Colors.yellow
                                              : Colors.white,
                                      fontWeight:
                                          rank == 1 ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Score: ${player.score}',
                                style: TextStyle(
                                  color:
                                      rank == 1 ? Colors.yellow : Colors.white,
                                  fontWeight:
                                      rank == 1 ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(GameConstants.greenFeltColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Back to Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Confetti effect
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Straight down
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

  List<Player> _getRankedPlayers(List<Player> players) {
    // Sort players by score in descending order (highest first)
    List<Player> sortedPlayers = List.from(players);
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    return sortedPlayers;
  }

  Color _getRankColor(int rank) {
    // Return different colors for different ranks
    switch (rank) {
      case 1:
        return Colors.amber; // Gold for 1st place
      case 2:
        return Colors.grey.shade400; // Silver for 2nd place
      case 3:
        return Colors.brown.shade300; // Bronze for 3rd place
      default:
        return Colors.grey.shade600; // Dark grey for 4th place
    }
  }
}
