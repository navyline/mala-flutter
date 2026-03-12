import 'package:flutter/material.dart';

/// [HistoryTile] is a specialized list item widget for displaying point transactions.
///
/// It dynamically adjusts its visual style (colors and icons) based on the
/// transaction [type], supporting both 'EARN' (add) and 'REDEEM' (subtract) actions.
class HistoryTile extends StatelessWidget {
  /// The descriptive name of the transaction.
  final String title;

  /// The amount of points involved in the transaction.
  final int points;

  /// The transaction category: 'EARN' for additions or 'REDEEM' for subtractions.
  final String type;

  /// The formatted date and time string of the activity.
  final String date;

  const HistoryTile({
    super.key,
    required this.title,
    required this.points,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 UI Logic: Determine visual feedback based on transaction type.
    final bool isEarn = type == 'EARN';
    final Color color = isEarn ? Colors.green : Colors.red;
    final Color bgColor = isEarn ? Colors.green.shade50 : Colors.red.shade50;

    // Choose icon based on the transaction direction.
    final IconData icon = isEarn
        ? Icons.add_circle_outline
        : Icons.remove_circle_outline;

    // Prefix '+' for earnings; subtractions use default number formatting.
    final String pointPrefix = isEarn ? '+' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔵 LEFT: Status Indicator (Icon with circular background)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // 🟡 CENTER: Transaction Details (Flexible width)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),

          // 🟢 RIGHT: Point Value (Color-coded)
          Text(
            '$pointPrefix$points',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
