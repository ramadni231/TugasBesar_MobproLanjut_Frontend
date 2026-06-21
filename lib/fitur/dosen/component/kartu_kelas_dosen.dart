import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class KartuKelasDosen extends StatelessWidget {
  final String matakuliah;
  final String waktu;
  final String ruang;
  final int hadir;
  final int total;
  final bool isSesiAktif;
  final VoidCallback onBukaPresensi;

  const KartuKelasDosen({
    super.key,
    required this.matakuliah,
    required this.waktu,
    required this.ruang,
    required this.hadir,
    required this.total,
    required this.isSesiAktif,
    required this.onBukaPresensi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return GestureDetector(
      onTap: onBukaPresensi,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSesiAktif
                ? Colors.blue.shade300
                : (isDarkMode ? theme.colors.border : Colors.grey.shade200),
            width: isSesiAktif ? 2 : 1,
          ),
        ),
        color: isSesiAktif
            ? Colors.blue.shade50.withValues(alpha: isDarkMode ? 0.1 : 0.6)
            : (isDarkMode ? theme.colors.card : Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      matakuliah,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colors.foreground,
                      ),
                    ),
                  ),
                  const Icon(FIcons.chevronRight, color: Colors.grey, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$waktu • $ruang',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hadir: $hadir/$total',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: theme.colors.foreground,
                    ),
                  ),
                  if (isSesiAktif)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Sesi Aktif',
                        style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
