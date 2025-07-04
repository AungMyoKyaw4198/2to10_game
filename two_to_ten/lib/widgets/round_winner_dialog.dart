import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../models/player.dart';

class RoundWinnerDialog extends StatelessWidget {
  final int roundNumber;
  final List<Player> players;
  final VoidCallback onDismiss;

  const RoundWinnerDialog({
    super.key,
    required this.roundNumber,
    required this.players,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate round results
    final roundResults = _calculateRoundResults();
    final roundWinner = roundResults.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.amber.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large trophy icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.amber.shade600],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Round number
              Text(
                'Round $roundNumber Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Round winner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Round Winner',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roundWinner.key,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${roundWinner.value} tricks won',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Round results table
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      'Round Results',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...roundResults.entries.map((entry) {
                      final player = players.firstWhere(
                        (p) => p.name == entry.key,
                      );
                      final isWinner = entry.key == roundWinner.key;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isWinner ? Colors.amber.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              isWinner
                                  ? Border.all(
                                    color: Colors.amber.shade300,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (isWinner)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                if (isWinner) const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontWeight:
                                        isWinner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isWinner
                                            ? Colors.amber.shade700
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Bid: ${player.currentBid}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Won: ${entry.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isWinner
                                            ? Colors.amber.shade700
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue to Next Round',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateRoundResults() {
    // Use the actual tricks won by each player for this round
    final results = <String, int>{};
    for (final player in players) {
      results[player.name] = player.tricksWon;
    }
    return results;
  }
}
