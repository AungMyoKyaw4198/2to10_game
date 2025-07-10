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
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _findNextPlayerToBid();
  }

  @override
  void didUpdateWidget(BidInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when the round changes
    if (oldWidget.currentRound != widget.currentRound) {
      _findNextPlayerToBid();
      _dialogShown = false; // Reset dialog flag when round changes
    }
  }

  @override
  void dispose() {
    _dialogShown = false; // Reset flag on dispose
    super.dispose();
  }

  void _findNextPlayerToBid() {
    // Start bidding from the player to the dealer's left (firstPlayer)
    int firstPlayer = widget.currentRound.firstPlayer;

    // Check if the first player still needs to bid
    if (widget.currentRound.bids[firstPlayer] < 0) {
      setState(() {
        _currentPlayerIndex = firstPlayer;
        _currentBid = 0;
      });
      return;
    }

    // Check subsequent players in clockwise order
    for (int i = 1; i < 4; i++) {
      int playerIndex = (firstPlayer + i) % 4;
      if (widget.currentRound.bids[playerIndex] < 0) {
        setState(() {
          _currentPlayerIndex = playerIndex;
          _currentBid = 0;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are still players who need to bid
    bool hasUnplacedBids = widget.currentRound.bids.any((bid) => bid < 0);

    if (!hasUnplacedBids) {
      _dialogShown = false;
      return const SizedBox.shrink(); // Hide widget if all bids are placed
    }

    // Show dialog for bidding only if not already shown and widget is mounted
    if (!_dialogShown && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Double-check that we still need to show the dialog
        if (mounted && widget.currentRound.bids.any((bid) => bid < 0)) {
          _showBidDialog(context);
        }
      });
    }

    return const SizedBox.shrink(); // Return empty widget since we're using dialog
  }

  void _showBidDialog(BuildContext context) {
    if (_dialogShown) return; // Prevent multiple dialogs

    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: Color(GameConstants.greenFeltColor),
              title: Text(
                '${GameConstants.defaultPlayerNames[_currentPlayerIndex]} - Enter your bid',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bid range info
                  Text(
                    'Bid range: 0 - ${widget.currentRound.roundNumber}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Bid selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            _currentBid > 0
                                ? () {
                                  setDialogState(() {
                                    _currentBid--;
                                  });
                                }
                                : null,
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '$_currentBid',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(GameConstants.greenFeltColor),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      IconButton(
                        onPressed:
                            _currentBid < widget.currentRound.roundNumber
                                ? () {
                                  setDialogState(() {
                                    _currentBid++;
                                  });
                                }
                                : null,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Current bid explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getBidExplanation(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              actions: [
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onBidSubmitted(_currentPlayerIndex, _currentBid);

                        // Check if widget is still mounted before calling setState
                        if (mounted) {
                          setState(() {
                            _currentBid = 0;
                          });
                          _findNextPlayerToBid();
                        }

                        Navigator.of(context).pop();

                        // Show next player's dialog if there are more bids to place
                        if (mounted &&
                            widget.currentRound.bids.any((bid) => bid < 0)) {
                          _dialogShown = false; // Reset flag for next player
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Check again if widget is still mounted before showing dialog
                            if (mounted) {
                              _showBidDialog(context);
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(GameConstants.greenFeltColor),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit Bid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getBidExplanation() {
    if (_currentBid == 0) {
      return 'Bid 0: Win 0 tricks = +0 points\nWin any tricks = +1 per trick (bags)';
    } else {
      return 'Bid $_currentBid: Hit exactly = +${_currentBid * 10} points\nOverbid = +${_currentBid * 10} + bags\nUnderbid = -${_currentBid * 10} points';
    }
  }
}
