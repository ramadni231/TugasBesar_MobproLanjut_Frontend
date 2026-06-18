import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class KartuKelasDosen extends StatelessWidget {
  final String matakuliah;
  final String waktu;
  final String ruang;
  final int hadir;
  final int total;
  final VoidCallback onBukaPresensi;

  const KartuKelasDosen({
    super.key,
    required this.matakuliah,
    required this.waktu,
    required this.ruang,
    required this.hadir,
    required this.total,
    required this.onBukaPresensi,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      title: Text(matakuliah),
      subtitle: Text('$waktu • $ruang'),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hadir: $hadir/$total'),
              FButton(
                onPress: onBukaPresensi,
                child: const Text('Buka Presensi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
