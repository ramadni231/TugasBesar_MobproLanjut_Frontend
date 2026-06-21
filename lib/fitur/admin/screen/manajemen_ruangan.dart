import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/ruangan_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/fitur/admin/component/modal_form_ruangan.dart';
import 'package:tugas_besar/fitur/admin/component/dialog_konfirmasi.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class ManajemenRuangan extends StatefulWidget {
  const ManajemenRuangan({super.key});

  @override
  State<ManajemenRuangan> createState() => _ManajemenRuanganState();
}

class _ManajemenRuanganState extends State<ManajemenRuangan> {
  final _controller = AdminController();
  List<Ruangan> _ruanganList = [];
  bool _sedangLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _sedangLoading = true);
    final data = await _controller.fetchRuangan();
    if (mounted) {
      setState(() {
        _ruanganList = data;
        _sedangLoading = false;
      });
    }
  }

  void _tambahRuangan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormRuangan(
        onSubmit: (data) async {
          final success = await _controller.tambahRuangan(data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Ruangan berhasil ditambahkan'));
          } else {
            showFToast(context: context, title: const Text('Gagal menambahkan ruangan'));
          }
        },
      ),
    );
  }

  void _editRuangan(Ruangan item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormRuangan(
        ruangan: item,
        onSubmit: (data) async {
          final success = await _controller.updateRuangan(item.id, data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Ruangan berhasil diperbarui'));
          } else {
            showFToast(context: context, title: const Text('Gagal memperbarui ruangan'));
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
        judul: 'Manajemen Ruangan',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahRuangan,
          ),
        ],
      ),
      body: _sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : _ruanganList.isEmpty
              ? const Center(child: Text('Belum ada ruangan yang ditambahkan.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ruanganList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _ruanganList[index];
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
                              item.namaRuangan,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kapasitas: ${item.kapasitas} • Radius: ${item.radiusMeter}m\n'
                              'Lokasi: (${item.latitude}, ${item.longitude})',
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
                                  onPress: () => _editRuangan(item),
                                  child: const Icon(FIcons.pencil, size: 16),
                                ),
                                FButton(
                                  variant: FButtonVariant.ghost,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => tampilkanKonfirmasiHapus(
                                    context: context,
                                    item: item.namaRuangan,
                                    onHapus: () async {
                                      final success = await _controller.hapusRuangan(item.id);
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
