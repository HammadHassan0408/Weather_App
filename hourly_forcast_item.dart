import 'package:flutter/material.dart';

class HourlyForecestItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperator;
  const HourlyForecestItem({
    super.key,
    required this.icon,
    required this.time,
    required this.temperator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(temperator),
          ],
        ),
      ),
    );
  }
}
