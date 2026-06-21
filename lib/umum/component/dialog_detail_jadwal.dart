import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

void tampilkanDetailJadwal({
  required BuildContext context,
  required Jadwal jadwal,
}) {
  final isDark = KontrolerTema().isDarkMode;
  final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
  final cardColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade50;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Detail Jadwal',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (jadwal.sesiAktif != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade600, width: 1),
                          ),
                          child: const Text(
                            'Sesi Aktif',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Matakuliah Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${jadwal.matakuliah.kodeMatkul} - ${jadwal.matakuliah.namaMatkul}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SKS: ${jadwal.matakuliah.sks} • Semester: ${jadwal.matakuliah.semester}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Details Table List
            _buildDetailRow(
              icon: FIcons.user,
              label: 'Dosen Pengampu',
              value: jadwal.dosen.nama,
              isDark: isDark,
            ),
            _buildDetailRow(
              icon: FIcons.mapPin,
              label: 'Ruangan',
              value: '${jadwal.ruangan.namaRuangan} (${jadwal.metode.toUpperCase()})',
              isDark: isDark,
            ),
            _buildDetailRow(
              icon: FIcons.clock,
              label: 'Waktu Kuliah',
              value: '${jadwal.hari}, ${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)}',
              isDark: isDark,
            ),
            _buildDetailRow(
              icon: FIcons.users,
              label: 'Kapasitas Ruangan',
              value: '${jadwal.ruangan.kapasitas} Mahasiswa',
              isDark: isDark,
            ),
            _buildDetailRow(
              icon: FIcons.compass,
              label: 'Toleransi Lokasi (GPS)',
              value: 'Radius ${jadwal.ruangan.radiusMeter} meter\nLat: ${jadwal.ruangan.latitude}, Lng: ${jadwal.ruangan.longitude}',
              isDark: isDark,
            ),
            if (jadwal.sesiAktif != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                icon: FIcons.check,
                label: 'Pertemuan Aktif Saat Ini',
                value: 'Pertemuan ke-${jadwal.sesiAktif!.pertemuanKe}',
                isDark: isDark,
                valueColor: Colors.blue,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow({
  required IconData icon,
  required String label,
  required String value,
  required bool isDark,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
