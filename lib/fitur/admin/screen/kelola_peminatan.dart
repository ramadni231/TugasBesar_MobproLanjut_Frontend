import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class KelolaPeminatan extends StatefulWidget {
  const KelolaPeminatan({super.key});

  @override
  State<KelolaPeminatan> createState() => _KelolaPeminatanState();
}

class _KelolaPeminatanState extends State<KelolaPeminatan> {
  final _controller = AdminController();
  List<Map<String, dynamic>> _listPeminatan = [];
  bool _sedangLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _sedangLoading = true);
    final data = await _controller.fetchPeminatan();
    // Hanya tampilkan yang 'menunggu'
    setState(() {
      _listPeminatan = data.where((p) => p['status'] == 'menunggu').toList();
      _sedangLoading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    final sukses = await _controller.updateStatusPeminatan(id, status);
    if (!mounted) return;

    if (sukses) {
      showFToast(context: context, title: const Text('Status diperbarui'));
      _loadData();
    } else {
      showFToast(context: context, title: const Text('Gagal memperbarui status'), variant: FToastVariant.destructive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Kelola Peminatan (Menunggu)',
      ),
      body: _sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : _listPeminatan.isEmpty
              ? const Center(child: Text('Tidak ada pengajuan peminatan baru.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listPeminatan.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _listPeminatan[index];
                    final mahasiswa = item['mahasiswa']['nama'];
                    final kodeMatkul = item['matakuliah']['kode_matkul'] ?? '';
                    final matkul = item['matakuliah']['nama_matkul'];
                    final semester = item['matakuliah']['semester'];

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
                              mahasiswa,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mengajukan: $kodeMatkul - $matkul (Semester $semester)',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FButton(
                                  variant: FButtonVariant.destructive,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => _updateStatus(item['id'], 'ditolak'),
                                  child: const Text('Tolak'),
                                ),
                                const SizedBox(width: 8),
                                FButton(
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => _updateStatus(item['id'], 'disetujui'),
                                  child: const Text('Setujui'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
