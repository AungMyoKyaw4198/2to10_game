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
        _buildCardCount(context),
        _buildPlayerHand(context),
      ],
    );
  }

  Widget _buildPlayerInfo(BuildContext context) {
    bool isPlayerTurn = _isPlayerTurn();
    bool hasPerfectStreak = _hasPerfectStreak();
    bool hasImmaculateStreak = _hasImmaculateStreak();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name with perfect streak effects
          Text(
            player.name,
            style: TextStyle(
              color: _getPlayerNameColor(
                isPlayerTurn,
                hasPerfectStreak,
                hasImmaculateStreak,
              ),
              fontWeight: FontWeight.bold,
              fontSize: hasPerfectStreak || hasImmaculateStreak ? 16 : 14,
              shadows: _getPlayerNameShadows(
                isPlayerTurn,
                hasPerfectStreak,
                hasImmaculateStreak,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Bid
          Text(
            player.currentBid >= 0 ? 'Bid: ${player.currentBid}' : 'Not Bid',
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

          // Perfect streak indicator
          if (hasPerfectStreak || hasImmaculateStreak) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasImmaculateStreak ? Colors.purple : Colors.amber,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (hasImmaculateStreak ? Colors.purple : Colors.amber)
                        .withValues(alpha: 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                hasImmaculateStreak ? 'IMMACULATE' : 'PERFECT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

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

  Color _getPlayerNameColor(
    bool isPlayerTurn,
    bool hasPerfectStreak,
    bool hasImmaculateStreak,
  ) {
    if (hasImmaculateStreak) return Colors.purple;
    if (hasPerfectStreak) return Colors.amber;
    if (isPlayerTurn) return Colors.yellow;
    return Colors.white;
  }

  List<Shadow>? _getPlayerNameShadows(
    bool isPlayerTurn,
    bool hasPerfectStreak,
    bool hasImmaculateStreak,
  ) {
    if (hasImmaculateStreak) {
      return [
        Shadow(color: Colors.purple.withValues(alpha: 0.8), blurRadius: 8),
        Shadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 4),
      ];
    }
    if (hasPerfectStreak) {
      return [
        Shadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 6),
        Shadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 3),
      ];
    }
    if (isPlayerTurn) {
      return [
        Shadow(color: Colors.yellow.withValues(alpha: 0.8), blurRadius: 4),
      ];
    }
    return null;
  }

  bool _hasPerfectStreak() {
    if (player.perfectRounds.isEmpty) return false;

    // Count how many perfect rounds the player has
    int perfectRoundsCount =
        player.perfectRounds.where((perfect) => perfect).length;

    // Show perfect streak if they have at least 3 consecutive perfect rounds
    return perfectRoundsCount >= 3;
  }

  bool _hasImmaculateStreak() {
    if (player.immaculateRounds.isEmpty) return false;

    // Count how many immaculate rounds the player has
    int immaculateRoundsCount =
        player.immaculateRounds.where((immaculate) => immaculate).length;

    // Show immaculate streak if they have at least 2 consecutive immaculate rounds
    return immaculateRoundsCount >= 2;
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

    // Determine card size and layout based on position
    double cardWidth = 30;
    double cardHeight = 40;
    int maxCardsPerRow = 5;

    // Adjust for left and right players to prevent overflow
    if (position == 'left' || position == 'right') {
      cardWidth = 20;
      cardHeight = 28;
      maxCardsPerRow = 4; // Fewer cards per row for side players
    }

    // Calculate dynamic height based on number of cards
    int cardsPerRow = position == 'left' || position == 'right' ? 4 : 5;
    int numberOfRows = (hand.length / cardsPerRow).ceil();
    double calculatedHeight =
        numberOfRows * (cardHeight + 1) + 8; // +1 for spacing, +8 for padding

    // Set maximum height for side players
    double maxHeight =
        position == 'left' || position == 'right' ? 200 : double.infinity;
    double finalHeight =
        calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    return Container(
      padding: const EdgeInsets.all(4),
      height: position == 'left' || position == 'right' ? finalHeight : null,
      child:
          finalHeight >= maxHeight &&
                  (position == 'left' || position == 'right')
              ? SingleChildScrollView(
                child: Wrap(
                  spacing: 1,
                  runSpacing: 1,
                  alignment: WrapAlignment.center,
                  children:
                      hand
                          .map(
                            (card) => _buildCardWidget(
                              context,
                              card,
                              isPlayerTurn,
                              cardWidth,
                              cardHeight,
                            ),
                          )
                          .toList(),
                ),
              )
              : Wrap(
                spacing: 1,
                runSpacing: 1,
                alignment: WrapAlignment.center,
                children:
                    hand
                        .map(
                          (card) => _buildCardWidget(
                            context,
                            card,
                            isPlayerTurn,
                            cardWidth,
                            cardHeight,
                          ),
                        )
                        .toList(),
              ),
    );
  }

  Widget _buildCardWidget(
    BuildContext context,
    game_card.Card card,
    bool isPlayable,
    double cardWidth,
    double cardHeight,
  ) {
    bool isPlayerTurn = _isPlayerTurn();

    // Adjust font size based on card size
    double fontSize = cardWidth > 25 ? 10 : 8;

    return GestureDetector(
      onTap: isPlayable ? () => onCardPlayed(card) : null,
      child: Container(
        width: cardWidth,
        height: cardHeight,
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
              fontSize: fontSize,
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

  Widget _buildCardCount(BuildContext context) {
    if (currentRound == null ||
        playerIndex >= currentRound!.playerHands.length) {
      return const SizedBox.shrink();
    }

    int cardCount = currentRound!.playerHands[playerIndex].length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        '$cardCount cards',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
