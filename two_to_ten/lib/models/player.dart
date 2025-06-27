class Player {
  final String name;
  int score;
  int bags;
  int currentBid;
  int tricksWon;
  List<bool> perfectRounds; // Track if player hit exact bid each round
  List<bool> immaculateRounds; // Track if player bid 0 and won 0 each round

  Player({
    required this.name,
    this.score = 0,
    this.bags = 0,
    this.currentBid = 0,
    this.tricksWon = 0,
    List<bool>? perfectRounds,
    List<bool>? immaculateRounds,
  }) : perfectRounds = perfectRounds ?? List.filled(9, false),
       immaculateRounds = immaculateRounds ?? List.filled(9, false);

  // Reset round-specific data
  void resetRound() {
    currentBid = 0;
    tricksWon = 0;
  }

  // Check if player has 4+ bags (warning threshold)
  bool get hasBagWarning => bags >= 4;

  // Check if player has broken their perfect streak
  bool get hasBrokenPerfectStreak {
    if (perfectRounds.isEmpty) return false;
    return perfectRounds.contains(false);
  }

  // Check if player has broken their immaculate streak
  bool get hasBrokenImmaculateStreak {
    if (immaculateRounds.isEmpty) return false;
    return immaculateRounds.contains(false);
  }

  // Get number of rounds not set (for tiebreaker)
  int get roundsNotSet {
    int count = 0;
    for (int i = 0; i < perfectRounds.length; i++) {
      if (perfectRounds[i] || (currentBid < tricksWon)) {
        count++;
      }
    }
    return count;
  }

  // Create a copy of the player with updated values
  Player copyWith({
    String? name,
    int? score,
    int? bags,
    int? currentBid,
    int? tricksWon,
    List<bool>? perfectRounds,
    List<bool>? immaculateRounds,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
      bags: bags ?? this.bags,
      currentBid: currentBid ?? this.currentBid,
      tricksWon: tricksWon ?? this.tricksWon,
      perfectRounds: perfectRounds ?? List.from(this.perfectRounds),
      immaculateRounds: immaculateRounds ?? List.from(this.immaculateRounds),
    );
  }

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'bags': bags,
      'currentBid': currentBid,
      'tricksWon': tricksWon,
      'perfectRounds': perfectRounds,
      'immaculateRounds': immaculateRounds,
    };
  }

  // Create from JSON for persistence
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      score: json['score'] as int,
      bags: json['bags'] as int,
      currentBid: json['currentBid'] as int,
      tricksWon: json['tricksWon'] as int,
      perfectRounds: List<bool>.from(json['perfectRounds'] as List),
      immaculateRounds: List<bool>.from(json['immaculateRounds'] as List),
    );
  }
}
