import 'package:flutter/material.dart';
import '../models/card.dart' as game_card;

class PlayingCardWidget extends StatelessWidget {
  final game_card.Card card;
  final bool faceUp;
  final bool isSelected;
  final bool isPlayable;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final String? playerName;
  final String? playerStats; // e.g. "Bid: 2 | Score: 30 | Bags: 1"

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.faceUp = false,
    this.isSelected = false,
    this.isPlayable = false,
    this.width = 48,
    this.height = 68,
    this.onTap,
    this.playerName,
    this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = GestureDetector(
      onTap: isPlayable && onTap != null ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: isSelected ? 2 : 0),
        decoration: BoxDecoration(
          color: faceUp ? Colors.white : Colors.blue.shade800,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected
                    ? Colors.orange
                    : (isPlayable ? Colors.yellow : Colors.grey.shade400),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child:
            faceUp
                ? Center(
                  child: Text(
                    card.displayString,
                    style: TextStyle(
                      color: Color(card.color),
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.44,
                      fontFamily: 'RobotoMono',
                      letterSpacing: card.displayString.length > 2 ? -1.5 : 0,
                      shadows:
                          isPlayable
                              ? [
                                Shadow(
                                  color: Colors.yellow.withOpacity(0.3),
                                  blurRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                : Center(
                  child: Icon(
                    Icons.style,
                    color: Colors.blue.shade200,
                    size: width * 0.6,
                  ),
                ),
      ),
    );

    if (playerName == null && playerStats == null) {
      return cardWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playerName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              playerName!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [Shadow(color: Colors.white, blurRadius: 2)],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        cardWidget,
        if (playerStats != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              playerStats!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
      ],
    );
  }
}
