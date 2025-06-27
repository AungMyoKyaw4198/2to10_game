import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/player_box.dart';
import '../widgets/bid_input_widget.dart';
import '../constants/game_constants.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

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
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlayerBox(
                player: gameState.players[0],
                position: 'top',
                playerIndex: 0,
                currentRound: gameState.currentRound,
                onCardPlayed: (card) => gameState.playCard(0, card),
              ),
            ),
          ),

          // Middle section with left and right players
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Left player
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlayerBox(
                      player: gameState.players[2],
                      position: 'left',
                      playerIndex: 2,
                      currentRound: gameState.currentRound,
                      onCardPlayed: (card) => gameState.playCard(2, card),
                    ),
                  ),
                ),

                // Center game area
                Expanded(
                  flex: 3,
                  child: _buildCenterGameArea(context, gameState),
                ),

                // Right player
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlayerBox(
                      player: gameState.players[1],
                      position: 'right',
                      playerIndex: 1,
                      currentRound: gameState.currentRound,
                      onCardPlayed: (card) => gameState.playCard(1, card),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom player
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlayerBox(
                player: gameState.players[3],
                position: 'bottom',
                playerIndex: 3,
                currentRound: gameState.currentRound,
                onCardPlayed: (card) => gameState.playCard(3, card),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterGameArea(BuildContext context, GameState gameState) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Round info
          Text(
            'Round ${gameState.currentRoundNumber}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Power suit display
          if (gameState.currentRound != null) ...[
            Text(
              'Power Suit: ${gameState.currentRound!.powerSuit}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 16),

            // Current trick display
            if (gameState.currentRound!.currentTrick.isNotEmpty) ...[
              Text(
                'Current Trick:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children:
                    gameState.currentRound!.currentTrick
                        .map(
                          (card) => Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              card.displayString,
                              style: TextStyle(
                                color: Color(card.color),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Game controls
            if (!gameState.currentRound!.allBidsPlaced) ...[
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
                ),
                child: const Text('Complete Round'),
              ),
            ] else ...[
              Text(
                'Playing tricks...',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGameCompleteScreen(BuildContext context, GameState gameState) {
    return Center(
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
                  gameState.players
                      .map(
                        (player) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Score: ${player.score}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () => gameState.startNewGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(GameConstants.greenFeltColor),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
