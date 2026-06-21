import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/fitur/admin/component/modal_form_jadwal.dart';
import 'package:tugas_besar/fitur/admin/component/dialog_konfirmasi.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class ManajemenJadwal extends StatefulWidget {
  const ManajemenJadwal({super.key});

  @override
  State<ManajemenJadwal> createState() => _ManajemenJadwalState();
}

class _ManajemenJadwalState extends State<ManajemenJadwal> {
  final _controller = AdminController();
  List<Jadwal> _jadwalList = [];
  bool _sedangLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _sedangLoading = true);
    final data = await _controller.fetchJadwal();
    if (mounted) {
      setState(() {
        _jadwalList = data;
        _sedangLoading = false;
      });
    }
  }

  void _tambahJadwal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormJadwal(
        onSubmit: (data) async {
          final success = await _controller.tambahJadwal(data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Jadwal berhasil ditambahkan'));
          } else {
            showFToast(context: context, title: const Text('Gagal menambahkan jadwal'));
          }
        },
      ),
    );
  }

  void _editJadwal(Jadwal item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormJadwal(
        jadwal: item,
        onSubmit: (data) async {
          final success = await _controller.updateJadwal(item.id, data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Jadwal berhasil diperbarui'));
          } else {
            showFToast(context: context, title: const Text('Gagal memperbarui jadwal'));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Manajemen Jadwal',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahJadwal,
          ),
        ],
      ),
      body: _sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : _jadwalList.isEmpty
              ? const Center(child: Text('Belum ada jadwal yang dibuat.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jadwalList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _jadwalList[index];
                    final isSesiAktif = item.sesiAktif != null;
                    return Card(
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
                              children: [
                                Expanded(
                                  child: Text(
                                    item.matakuliah.namaMatkul,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.foreground,
                                    ),
                                  ),
                                ),
                                if (isSesiAktif) ...[
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
                              '${item.hari}, ${item.jamMulai.substring(0, 5)} - ${item.jamSelesai.substring(0, 5)} (${item.metode.toUpperCase()})\n'
                              'Ruang: ${item.ruangan.namaRuangan}\n'
                              'Dosen: ${item.dosen.nama}',
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
                                  variant: FButtonVariant.ghost,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => Navigator.pushNamed(
                                    context,
                                    '/admin/rekap',
                                    arguments: item,
                                  ),
                                  child: const Icon(Icons.assessment, size: 16),
                                ),
                                FButton(
                                  variant: FButtonVariant.ghost,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => _editJadwal(item),
                                  child: const Icon(FIcons.pencil, size: 16),
                                ),
                                FButton(
                                  variant: FButtonVariant.ghost,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => tampilkanKonfirmasiHapus(
                                    context: context,
                                    item: 'jadwal ${item.matakuliah.namaMatkul}',
                                    onHapus: () async {
                                      final success = await _controller.hapusJadwal(item.id);
                                      if (success) _loadData();
                                    },
                                  ),
                                  child: const Icon(FIcons.trash2, size: 16),
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
