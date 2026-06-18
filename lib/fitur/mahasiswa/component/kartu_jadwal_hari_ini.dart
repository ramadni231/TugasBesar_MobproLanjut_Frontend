import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class KartuJadwalHariIni extends StatelessWidget {
  final String matakuliah;
  final String waktu;
  final String ruang;
  final VoidCallback onScan;

  const KartuJadwalHariIni({
    super.key,
    required this.matakuliah,
    required this.waktu,
    required this.ruang,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      title: Text(matakuliah),
      subtitle: Text('$waktu • $ruang'),
      child: Column(
        children: [
          const SizedBox(height: 12),
          FButton(
            onPress: onScan,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FIcons.qrCode, size: 18),
                SizedBox(width: 8),
                Text('Presensi Sekarang'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
