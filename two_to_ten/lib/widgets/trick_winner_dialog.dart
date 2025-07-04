import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class TrickWinnerDialog extends StatelessWidget {
  final String winnerName;
  final VoidCallback onDismiss;

  const TrickWinnerDialog({
    super.key,
    required this.winnerName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),

            // Winner text
            Text(
              'Trick Winner!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Winner name
            Text(
              winnerName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Continue button
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
