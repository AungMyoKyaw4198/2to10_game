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

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.faceUp = false,
    this.isSelected = false,
    this.isPlayable = false,
    this.width = 40,
    this.height = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      fontSize: width * 0.45,
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
  }
}
