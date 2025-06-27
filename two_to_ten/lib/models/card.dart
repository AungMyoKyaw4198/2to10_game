import '../constants/game_constants.dart';

class Card {
  final String suit;
  final String rank;

  const Card({required this.suit, required this.rank});

  // Get the numeric value of the card for comparison
  int get value {
    switch (rank) {
      case 'A':
        return 14;
      case 'K':
        return 13;
      case 'Q':
        return 12;
      case 'J':
        return 11;
      default:
        return int.parse(rank);
    }
  }

  // Get the color of the card (for UI)
  int get color {
    switch (suit) {
      case '♠':
      case '♣':
        return GameConstants.spadesColor;
      case '♥':
      case '♦':
        return GameConstants.heartsColor;
      default:
        return GameConstants.textColor;
    }
  }

  // Display string for the card
  String get displayString => '$suit$rank';

  // Compare two cards based on their values
  int compareTo(Card other) {
    return value.compareTo(other.value);
  }

  @override
  String toString() => displayString;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
