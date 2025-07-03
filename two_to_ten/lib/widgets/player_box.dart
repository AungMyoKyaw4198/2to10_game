import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_to_ten/widgets/playing_card_widget.dart';
import '../models/card.dart' as game_card;
import '../models/player.dart';
import '../models/round.dart';
import '../providers/game_state.dart';

class PlayerBox extends StatefulWidget {
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
  _PlayerBoxState createState() => _PlayerBoxState();
}

class _PlayerBoxState extends State<PlayerBox> {
  int? _selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    bool isPlayerTurn = _isPlayerTurn();
    return GestureDetector(
      onTap: isPlayerTurn ? _showCardSelectionSheet : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPlayerTurn ? Colors.yellow : Colors.white.withOpacity(0.3),
            width: isPlayerTurn ? 2 : 1,
          ),
          boxShadow:
              isPlayerTurn
                  ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child: _buildPlayerContent(context),
      ),
    );
  }

  void _showCardSelectionSheet() async {
    if (widget.currentRound == null ||
        widget.playerIndex >= widget.currentRound!.playerHands.length)
      return;
    List<game_card.Card> hand =
        widget.currentRound!.playerHands[widget.playerIndex];
    double cardWidth = 40;
    double cardHeight = 56;
    int? selectedIdx = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < hand.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: PlayingCardWidget(
                        card: hand[i],
                        faceUp: true,
                        isSelected: _selectedCardIndex == i,
                        isPlayable: _isPlayerTurn() && _isCardPlayable(hand[i]),
                        width: cardWidth,
                        height: cardHeight,
                        onTap:
                            _isPlayerTurn() && _isCardPlayable(hand[i])
                                ? () {
                                  Navigator.of(context).pop(i);
                                }
                                : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selectedIdx != null) {
      setState(() => _selectedCardIndex = selectedIdx);
      widget.onCardPlayed(hand[selectedIdx]);
      setState(() => _selectedCardIndex = null);
    }
  }

  Widget _buildPlayerContent(BuildContext context) {
    final isVertical = widget.position == 'top' || widget.position == 'bottom';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayerInfo(context),
        const SizedBox(height: 8),
        _buildCardCount(context),
        if (isVertical)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildPlayerHand(context),
            ),
          )
        else
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
            widget.player.name,
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
            widget.player.currentBid >= 0
                ? 'Bid: ${widget.player.currentBid}'
                : 'Not Bid',
            style: TextStyle(
              color: isPlayerTurn ? Colors.yellow : Colors.white70,
              fontSize: 12,
            ),
          ),

          // Score
          Text(
            'Score: ${widget.player.score}',
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
                'Bags: ${widget.player.bags}',
                style: TextStyle(
                  color:
                      widget.player.hasBagWarning
                          ? Colors.red
                          : (isPlayerTurn ? Colors.yellow : Colors.white70),
                  fontSize: 12,
                  fontWeight:
                      widget.player.hasBagWarning ? FontWeight.bold : null,
                ),
              ),
              if (widget.player.hasBagWarning) ...[
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
    if (widget.player.perfectRounds.isEmpty) return false;

    // Count how many perfect rounds the player has
    int perfectRoundsCount =
        widget.player.perfectRounds.where((perfect) => perfect).length;

    // Show perfect streak if they have at least 3 consecutive perfect rounds
    return perfectRoundsCount >= 3;
  }

  bool _hasImmaculateStreak() {
    if (widget.player.immaculateRounds.isEmpty) return false;

    // Count how many immaculate rounds the player has
    int immaculateRoundsCount =
        widget.player.immaculateRounds.where((immaculate) => immaculate).length;

    // Show immaculate streak if they have at least 2 consecutive immaculate rounds
    return immaculateRoundsCount >= 2;
  }

  Widget _buildPlayerHand(BuildContext context) {
    if (widget.currentRound == null ||
        widget.playerIndex >= widget.currentRound!.playerHands.length ||
        widget.currentRound!.playerHands[widget.playerIndex].isEmpty) {
      return const SizedBox.shrink();
    }
    List<game_card.Card> hand =
        widget.currentRound!.playerHands[widget.playerIndex];
    double cardWidth = 40;
    double cardHeight = 56;
    return SizedBox(
      height: cardHeight + 8,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              hand
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: PlayingCardWidget(
                        card: card,
                        faceUp: false,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildCardCount(BuildContext context) {
    if (widget.currentRound == null ||
        widget.playerIndex >= widget.currentRound!.playerHands.length) {
      return const SizedBox.shrink();
    }

    int cardCount = widget.currentRound!.playerHands[widget.playerIndex].length;

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

  bool _isCardPlayable(game_card.Card card) {
    // Implement the logic to determine if a card is playable
    // This is a placeholder and should be replaced with the actual implementation
    return true; // Placeholder return, actual implementation needed
  }

  bool _isPlayerTurn() {
    if (widget.currentRound == null) return false;

    // If bidding phase, no one can play cards
    if (!widget.currentRound!.allBidsPlaced) return false;

    // If all tricks complete, no one can play cards
    if (widget.currentRound!.areAllTricksComplete) return false;

    // Determine whose turn it is based on current trick
    int currentTrickSize = widget.currentRound!.currentTrick.length;

    // First player to play in a trick is the winner of the previous trick
    // or player 0 if it's the first trick
    int firstPlayer =
        widget.currentRound!.trickWinners.isNotEmpty
            ? widget.currentRound!.trickWinners.last
            : 0;

    // Calculate whose turn it is
    int currentPlayer = (firstPlayer + currentTrickSize) % 4;

    return currentPlayer == widget.playerIndex;
  }
}
