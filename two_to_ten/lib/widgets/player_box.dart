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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: _buildPlayerContent(context),
    );
  }

  Widget _buildPlayerContent(BuildContext context) {
    switch (position) {
      case 'top':
        return _buildTopPlayer(context);
      case 'bottom':
        return _buildBottomPlayer(context);
      case 'left':
        return _buildLeftPlayer(context);
      case 'right':
        return _buildRightPlayer(context);
      default:
        return _buildTopPlayer(context);
    }
  }

  Widget _buildTopPlayer(BuildContext context) {
    return Column(
      children: [
        _buildPlayerInfo(context),
        const SizedBox(height: 8),
        _buildPlayerHand(context),
      ],
    );
  }

  Widget _buildBottomPlayer(BuildContext context) {
    return Column(
      children: [
        _buildPlayerHand(context),
        const SizedBox(height: 8),
        _buildPlayerInfo(context),
      ],
    );
  }

  Widget _buildLeftPlayer(BuildContext context) {
    return Row(
      children: [
        _buildPlayerInfo(context),
        const SizedBox(width: 8),
        Expanded(child: _buildPlayerHand(context)),
      ],
    );
  }

  Widget _buildRightPlayer(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildPlayerHand(context)),
        const SizedBox(width: 8),
        _buildPlayerInfo(context),
      ],
    );
  }

  Widget _buildPlayerInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with strike-through if perfect streak broken
          Text(
            player.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration:
                  player.hasBrokenPerfectStreak
                      ? TextDecoration.lineThrough
                      : null,
            ),
          ),

          const SizedBox(height: 4),

          // Bid
          Text(
            'Bid: ${player.currentBid}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          // Score
          Text(
            'Score: ${player.score}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          // Bags with warning
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bags: ${player.bags}',
                style: TextStyle(
                  color: player.hasBagWarning ? Colors.red : Colors.white70,
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
    return GestureDetector(
      onTap: isPlayable ? () => onCardPlayed(card) : null,
      child: Container(
        width: 30,
        height: 40,
        decoration: BoxDecoration(
          color: isPlayable ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPlayable ? Color(card.color) : Colors.grey,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            card.displayString,
            style: TextStyle(
              color: Color(card.color),
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
