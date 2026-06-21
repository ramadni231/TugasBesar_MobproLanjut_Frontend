import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/dosen/controller/dosen_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';
import 'package:tugas_besar/umum/component/dialog_detail_jadwal.dart';

class JadwalMengajar extends StatefulWidget {
  const JadwalMengajar({super.key});

  @override
  State<JadwalMengajar> createState() => _JadwalMengajarState();
}

class _JadwalMengajarState extends State<JadwalMengajar> {
  final _controller = DosenController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateState);
    _controller.fetchJadwal();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;
    final listHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Jadwal Mengajar',
      ),
      body: _controller.sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.jadwalMengajar.isEmpty
              ? const Center(child: Text('Tidak ada jadwal mengajar.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: listHari.length,
                  separatorBuilder: (context, index) {
                    final hari = listHari[index];
                    final jadwalHari = _controller.jadwalMengajar
                        .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
                        .toList();
                    return jadwalHari.isEmpty ? const SizedBox.shrink() : const SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    final hari = listHari[index];
                    final jadwalHari = _controller.jadwalMengajar
                        .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
                        .toList();

                    if (jadwalHari.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hari,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...jadwalHari.map((j) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: j.sesiAktif != null
                                        ? Colors.blue.shade300
                                        : (isDarkMode ? theme.colors.border : Colors.grey.shade200),
                                    width: j.sesiAktif != null ? 2 : 1,
                                  ),
                                ),
                                color: j.sesiAktif != null
                                    ? Colors.blue.shade50.withValues(alpha: isDarkMode ? 0.1 : 0.6)
                                    : (isDarkMode ? theme.colors.card : Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${j.matakuliah.kodeMatkul} - ${j.matakuliah.namaMatkul}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colors.foreground,
                                              ),
                                            ),
                                          ),
                                          if (j.sesiAktif != null) ...[
                                            Icon(FIcons.check, color: Colors.green, size: 16),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Aktif',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${j.jamMulai.substring(0, 5)} - ${j.jamSelesai.substring(0, 5)} • ${j.ruangan.namaRuangan} • ${j.metode.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          FButton.icon(
                                            variant: FButtonVariant.outline,
                                            size: FButtonSizeVariant.sm,
                                            onPress: () {
                                              tampilkanDetailJadwal(context: context, jadwal: j);
                                            },
                                            child: const Icon(FIcons.info, size: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          FButton.icon(
                                            variant: j.sesiAktif != null ? FButtonVariant.primary : FButtonVariant.outline,
                                            size: FButtonSizeVariant.sm,
                                            onPress: () async {
                                              await Navigator.pushNamed(context, '/dosen/detail', arguments: j);
                                              _controller.fetchJadwal();
                                            },
                                            child: const Icon(FIcons.qrCode, size: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    );
                  },
                ),
    );
  }
}


