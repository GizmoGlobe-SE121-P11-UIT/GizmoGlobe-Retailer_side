import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text = status.toString();

    if (text.toLowerCase().contains('cancelled') || text.toLowerCase().contains('unpaid') || text.toLowerCase().contains('denied') || text.toLowerCase().contains('inactive') || text.toLowerCase().contains('discontinued')) {
      color = Colors.red;
      icon = Icons.cancel;
    } else if (text.toLowerCase().contains('pending') || text.toLowerCase().contains('preparing') || text.toLowerCase().contains('shipping') || text.toLowerCase().contains('processing')) {
      color = Colors.orange;
      icon = Icons.pending;
    } else if (text.toLowerCase().contains('paid') || text.toLowerCase().contains('completed') || text.toLowerCase().contains('active')) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.grey;
      icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text.split('.').last,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 