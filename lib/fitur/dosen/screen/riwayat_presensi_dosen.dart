import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/dosen/controller/dosen_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class RiwayatPresensiDosen extends StatefulWidget {
  const RiwayatPresensiDosen({super.key});

  @override
  State<RiwayatPresensiDosen> createState() => _RiwayatPresensiDosenState();
}

class _RiwayatPresensiDosenState extends State<RiwayatPresensiDosen> {
  final _controller = DosenController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateState);
    _searchController.addListener(_updateState);
    _controller.fetchJadwal();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _searchController.removeListener(_updateState);
    _searchController.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    final filteredJadwal = _controller.jadwalMengajar.where((j) {
      return j.matakuliah.namaMatkul.toLowerCase().contains(query) ||
             j.matakuliah.kodeMatkul.toLowerCase().contains(query) ||
             j.ruangan.namaRuangan.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Riwayat Presensi',
      ),
      body: _controller.sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Card(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(FIcons.search, color: theme.colors.mutedForeground, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: theme.colors.foreground),
                              decoration: InputDecoration(
                                hintText: 'Cari mata kuliah atau kode...',
                                hintStyle: TextStyle(color: theme.colors.mutedForeground),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredJadwal.isEmpty
                        ? const Center(child: Text('Tidak ada mata kuliah.'))
                        : ListView.separated(
                            itemCount: filteredJadwal.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = filteredJadwal[index];
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
                                      Text(
                                        '${item.matakuliah.kodeMatkul} - ${item.matakuliah.namaMatkul}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colors.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Hari: ${item.hari} • Jam: ${item.jamMulai.substring(0, 5)} - ${item.jamSelesai.substring(0, 5)}\n'
                                        'Ruangan: ${item.ruangan.namaRuangan} • ${item.metode.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: FButton(
                                          size: FButtonSizeVariant.sm,
                                          onPress: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/dosen/detail',
                                              arguments: item,
                                            );
                                          },
                                          child: const Text('Lihat Sesi'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
