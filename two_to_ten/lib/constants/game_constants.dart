class GameConstants {
  // Suits
  static const List<String> suits = ['♠', '♥', '♦', '♣'];
  static const List<String> suitNames = [
    'Spades',
    'Hearts',
    'Diamonds',
    'Clubs',
  ];

  // Card ranks (2-10, J, Q, K, A)
  static const List<String> ranks = [
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
    'A',
  ];

  // Game settings
  static const int minRound = 2;
  static const int maxRound = 10;
  static const int totalPlayers = 4;
  static const int totalRounds = maxRound - minRound + 1; // 9 rounds

  // Scoring constants
  static const int exactBidBonus = 10;
  static const int bagPenalty = 50; // penalty for every 5 bags
  static const int bagsForPenalty = 5;
  static const int perfectGameBonus = 50;
  static const int immaculateGameBonus = 100;

  // Player names
  static const List<String> defaultPlayerNames = [
    'Alex',
    'James',
    'John',
    'Tom',
  ];

  // Colors
  static const int greenFeltColor = 0xFF2D5A27;
  static const int cardBackgroundColor = 0xFFFFFFFF;
  static const int textColor = 0xFF000000;
  static const int spadesColor = 0xFF000000;
  static const int heartsColor = 0xFFD32F2F;
  static const int diamondsColor = 0xFFD32F2F;
  static const int clubsColor = 0xFF000000;

  // TODO: Remove this once testing is done
  // Development/Testing Settings
  static const bool showAllCardsDuringBidding =
      true; // Set to false for production
  // When true: All players' cards are visible during bidding phase (for testing)
  // When false: Cards are face down during bidding phase (for production)
}
