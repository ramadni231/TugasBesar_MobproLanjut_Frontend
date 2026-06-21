import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class RiwayatPresensi extends StatefulWidget {
  const RiwayatPresensi({super.key});

  @override
  State<RiwayatPresensi> createState() => _RiwayatPresensiState();
}

class _RiwayatPresensiState extends State<RiwayatPresensi> {
  final _controller = MahasiswaController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _controller.fetchJadwal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Riwayat Presensi',
      ),
      body: _controller.sedangLoading 
        ? const Center(child: CircularProgressIndicator())
        : _controller.jadwal.isEmpty
          ? const Center(child: Text('Belum ada jadwal terdaftar.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.jadwal.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final j = _controller.jadwal[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/mahasiswa/jadwal/detail',
                      arguments: j,
                    );
                  },
                  child: Card(
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
                              Expanded(
                                child: Text(
                                  '${j.matakuliah.kodeMatkul} - ${j.matakuliah.namaMatkul}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colors.foreground,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(FIcons.chevronRight, size: 18, color: theme.colors.primary),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${j.hari}, ${j.jamMulai.substring(0, 5)} - ${j.jamSelesai.substring(0, 5)} • ${j.ruangan.namaRuangan}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
