import 'package:flutter/material.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(10), // 🔧 Giảm padding từ 12 → 10
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🔧 Quan trọng: distribute space evenly
          mainAxisSize: MainAxisSize.max, // 🔧 Sử dụng toàn bộ không gian available
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 9, // 🔧 Giảm font size từ 10 → 9
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2, // Allow wrapping
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3), // 🔧 Giảm padding từ 4 → 3
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3), // 🔧 Giảm border radius
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 12, // 🔧 Giảm icon size từ 14 → 12
                  ),
                ),
              ],
            ),
            // 🔧 Spacer để push value xuống dưới
            Expanded(
              child: Align( // 🔧 Align center để value ở giữa không gian còn lại
                alignment: Alignment.center,
                child: FittedBox( // Ensures text scales to fit
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14, // 🔧 Giảm font size từ 16 → 14
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 