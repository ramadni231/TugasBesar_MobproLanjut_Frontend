import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class KartuJadwalHariIni extends StatelessWidget {
  final String matakuliah;
  final String namaDosen;
  final String waktu;
  final String ruang;
  final bool isSesiAktif;
  final bool isSesiHabis;
  final VoidCallback onTap;

  const KartuJadwalHariIni({
    super.key,
    required this.matakuliah,
    required this.namaDosen,
    required this.waktu,
    required this.ruang,
    required this.isSesiAktif,
    required this.isSesiHabis,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return GestureDetector(
      onTap: onTap,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (isSesiAktif)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FIcons.radio, size: 12, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Sesi Aktif',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$namaDosen\n$waktu • $ruang',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (!isSesiAktif)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSesiHabis 
                          ? Colors.red.withValues(alpha: isDarkMode ? 0.1 : 0.05) 
                          : Colors.amber.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSesiHabis 
                              ? Colors.red.withValues(alpha: 0.3) 
                              : Colors.amber.withValues(alpha: 0.3)
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSesiHabis ? Icons.error_outline : Icons.info_outline,
                          color: isSesiHabis ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade800) : (isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSesiHabis
                                ? 'Sesi presensi sudah habis'
                                : 'Kelas belum dimulai (menunggu dosen membuka presensi)',
                            style: TextStyle(
                              color: isSesiHabis ? (isDarkMode ? Colors.red.shade300 : Colors.red.shade900) : (isDarkMode ? Colors.amber.shade300 : Colors.amber.shade900),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
