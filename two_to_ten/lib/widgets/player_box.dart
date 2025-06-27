import 'package:flutter/material.dart';
import '../models/card.dart' as game_card;
import '../models/player.dart';
import '../models/round.dart';

class PlayerBox extends StatelessWidget {
  final Player player;
  final String position; // 'top', 'bottom', 'left', 'right'
  final int playerIndex;
  final Round? currentRound;
  final Function(game_card.Card) onCardPlayed;

  const PlayerBox({
    super.key,
    required this.player,
    required this.position,
    required this.playerIndex,
    this.currentRound,
    required this.onCardPlayed,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlayerTurn = _isPlayerTurn();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isPlayerTurn
                  ? Colors.yellow
                  : Colors.white.withValues(alpha: 0.3),
          width: isPlayerTurn ? 2 : 1,
        ),
        boxShadow:
            isPlayerTurn
                ? [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: _buildPlayerContent(context),
    );
  }

  Widget _buildPlayerContent(BuildContext context) {
    // All players now use the same layout with cards at the bottom
    return Column(
      children: [
        _buildPlayerInfo(context),
        const SizedBox(height: 8),
        _buildPlayerHand(context),
      ],
    );
  }

  Widget _buildPlayerInfo(BuildContext context) {
    bool isPlayerTurn = _isPlayerTurn();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with strike-through if perfect streak broken
          Text(
            player.name,
            style: TextStyle(
              color: isPlayerTurn ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold,
              decoration:
                  player.hasBrokenPerfectStreak
                      ? TextDecoration.lineThrough
                      : null,
              shadows:
                  isPlayerTurn
                      ? [
                        Shadow(
                          color: Colors.yellow.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ]
                      : null,
            ),
          ),

          const SizedBox(height: 4),

          // Bid
          Text(
            'Bid: ${player.currentBid}',
            style: TextStyle(
              color: isPlayerTurn ? Colors.yellow : Colors.white70,
              fontSize: 12,
            ),
          ),

          // Score
          Text(
            'Score: ${player.score}',
            style: TextStyle(
              color: isPlayerTurn ? Colors.yellow : Colors.white70,
              fontSize: 12,
            ),
          ),

          // Bags with warning
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bags: ${player.bags}',
                style: TextStyle(
                  color:
                      player.hasBagWarning
                          ? Colors.red
                          : (isPlayerTurn ? Colors.yellow : Colors.white70),
                  fontSize: 12,
                  fontWeight: player.hasBagWarning ? FontWeight.bold : null,
                ),
              ),
              if (player.hasBagWarning) ...[
                const SizedBox(width: 4),
                const Icon(Icons.warning, color: Colors.red, size: 12),
              ],
            ],
          ),

          // Turn indicator
          if (isPlayerTurn) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'YOUR TURN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerHand(BuildContext context) {
    if (currentRound == null ||
        playerIndex >= currentRound!.playerHands.length ||
        currentRound!.playerHands[playerIndex].isEmpty) {
      return const SizedBox.shrink();
    }

    List<game_card.Card> hand = currentRound!.playerHands[playerIndex];

    // Check if it's this player's turn to play
    bool isPlayerTurn = _isPlayerTurn();

    return Container(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children:
            hand
                .map((card) => _buildCardWidget(context, card, isPlayerTurn))
                .toList(),
      ),
    );
  }

  Widget _buildCardWidget(
    BuildContext context,
    game_card.Card card,
    bool isPlayable,
  ) {
    bool isPlayerTurn = _isPlayerTurn();

    return GestureDetector(
      onTap: isPlayable ? () => onCardPlayed(card) : null,
      child: Container(
        width: 30,
        height: 40,
        decoration: BoxDecoration(
          color: isPlayable ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color:
                isPlayable
                    ? (isPlayerTurn ? Colors.yellow : Color(card.color))
                    : Colors.grey,
            width: isPlayable && isPlayerTurn ? 2 : 1,
          ),
          boxShadow:
              isPlayable && isPlayerTurn
                  ? [
                    BoxShadow(
                      color: Colors.yellow.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            card.displayString,
            style: TextStyle(
              color:
                  isPlayable && isPlayerTurn
                      ? Colors.yellow.shade800
                      : Color(card.color),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows:
                  isPlayable && isPlayerTurn
                      ? [
                        Shadow(
                          color: Colors.yellow.withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ]
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  bool _isPlayerTurn() {
    if (currentRound == null) return false;

    // If bidding phase, no one can play cards
    if (!currentRound!.allBidsPlaced) return false;

    // If all tricks complete, no one can play cards
    if (currentRound!.areAllTricksComplete) return false;

    // Determine whose turn it is based on current trick
    int currentTrickSize = currentRound!.currentTrick.length;

    // First player to play in a trick is the winner of the previous trick
    // or player 0 if it's the first trick
    int firstPlayer =
        currentRound!.trickWinners.isNotEmpty
            ? currentRound!.trickWinners.last
            : 0;

    // Calculate whose turn it is
    int currentPlayer = (firstPlayer + currentTrickSize) % 4;

    return currentPlayer == playerIndex;
  }
}
