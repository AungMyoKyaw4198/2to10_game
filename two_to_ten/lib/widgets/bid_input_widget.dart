import 'package:flutter/material.dart';
import '../models/round.dart';
import '../constants/game_constants.dart';

class BidInputWidget extends StatefulWidget {
  final Round currentRound;
  final Function(int playerIndex, int bid) onBidSubmitted;

  const BidInputWidget({
    super.key,
    required this.currentRound,
    required this.onBidSubmitted,
  });

  @override
  State<BidInputWidget> createState() => _BidInputWidgetState();
}

class _BidInputWidgetState extends State<BidInputWidget> {
  int _currentPlayerIndex = 0;
  int _currentBid = 0;

  @override
  void initState() {
    super.initState();
    _findNextPlayerToBid();
  }

  void _findNextPlayerToBid() {
    for (int i = 0; i < widget.currentRound.bids.length; i++) {
      if (widget.currentRound.bids[i] < 0) {
        _currentPlayerIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${GameConstants.defaultPlayerNames[_currentPlayerIndex]} - Enter your bid:',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Bid selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _currentBid > 0
                        ? () => setState(() => _currentBid--)
                        : null,
                icon: const Icon(Icons.remove, color: Colors.white),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentBid',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(GameConstants.greenFeltColor),
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _currentBid < widget.currentRound.roundNumber
                        ? () => setState(() => _currentBid++)
                        : null,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bid range info
          Text(
            'Bid range: 0 - ${widget.currentRound.roundNumber}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 16),

          // Submit button
          ElevatedButton(
            onPressed: () {
              widget.onBidSubmitted(_currentPlayerIndex, _currentBid);
              _currentBid = 0;
              _findNextPlayerToBid();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(GameConstants.greenFeltColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Submit Bid',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
