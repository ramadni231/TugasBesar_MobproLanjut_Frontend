import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class IndikatorGps extends StatelessWidget {
  final bool dalamRadius;
  final double jarak;

  const IndikatorGps({
    super.key,
    required this.dalamRadius,
    required this.jarak,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Row(
        children: [
          Icon(
            dalamRadius ? FIcons.mapPin : FIcons.mapPinOff,
            color: dalamRadius ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dalamRadius ? 'Dalam Radius Presensi' : 'Luar Radius Presensi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dalamRadius ? Colors.green : Colors.red,
                  ),
                ),
                Text('Jarak anda: ${jarak.toStringAsFixed(1)} meter'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
