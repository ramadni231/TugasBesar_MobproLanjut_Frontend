import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
    return FCard(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (icon != null) Icon(icon, size: 20, color: Colors.blue),
        ],
      ),
      subtitle: Text(label),
      child: const SizedBox.shrink(),
    );
  }
}
