import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class KartuStatistik extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const KartuStatistik({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? theme.colors.border : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDarkMode ? theme.colors.card : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colors.foreground,
                  ),
                ),
                if (icon != null) Icon(icon, size: 20, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
