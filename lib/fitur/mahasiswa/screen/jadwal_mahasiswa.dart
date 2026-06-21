import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';


class JadwalMahasiswa extends StatefulWidget {
  const JadwalMahasiswa({super.key});

  @override
  State<JadwalMahasiswa> createState() => _JadwalMahasiswaState();
}

class _JadwalMahasiswaState extends State<JadwalMahasiswa> {
  final _controller = MahasiswaController();
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
    _searchController.dispose();
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
        judul: 'Jadwal Kuliah',
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
                                hintText: 'Cari mata kuliah, kode, dosen, atau ruang...',
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
                    child: _controller.jadwal.isEmpty
                        ? const Center(child: Text('Tidak ada jadwal kuliah.'))
                        : Builder(
                            builder: (context) {
                              final query = _searchController.text.toLowerCase();
                              
                              final filteredJadwal = _controller.jadwal.where((j) {
                                return j.matakuliah.namaMatkul.toLowerCase().contains(query) ||
                                    j.matakuliah.kodeMatkul.toLowerCase().contains(query) ||
                                    j.ruangan.namaRuangan.toLowerCase().contains(query) ||
                                    j.dosen.nama.toLowerCase().contains(query);
                              }).toList();

                              if (filteredJadwal.isEmpty) {
                                  return const Center(child: Text('Tidak ada jadwal yang cocok.'));
                              }

                              return ListView.separated(
                                itemCount: listHari.length,
                                separatorBuilder: (context, index) {
                                  final hari = listHari[index];
                                  final jadwalHari = filteredJadwal
                                      .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
                                      .toList();
                                  return jadwalHari.isEmpty ? const SizedBox.shrink() : const SizedBox(height: 16);
                                },
                                itemBuilder: (context, index) {
                                  final hari = listHari[index];
                                  final jadwalHari = filteredJadwal
                                      .where((j) => j.hari.toLowerCase() == hari.toLowerCase())
                                      .toList();

                                  if (jadwalHari.isEmpty) return const SizedBox.shrink();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hari,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...jadwalHari.map((j) => Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                  context,
                                                  '/mahasiswa/jadwal/detail',
                                                  arguments: j,
                                                );
                                                _controller.fetchJadwal();
                                              },
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
                                                        '${j.jamMulai.substring(0, 5)} - ${j.jamSelesai.substring(0, 5)} • ${j.ruangan.namaRuangan} • ${j.metode.toUpperCase()}\n'
                                                        'Dosen: ${j.dosen.nama}',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: theme.colors.mutedForeground,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  );
                                },
                              );
                            }
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
