import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/izin_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class ValidasiIzinAdmin extends StatefulWidget {
  const ValidasiIzinAdmin({super.key});

  @override
  State<ValidasiIzinAdmin> createState() => _ValidasiIzinAdminState();
}

class _ValidasiIzinAdminState extends State<ValidasiIzinAdmin> {
  final _controller = AdminController();
  List<Izin> _listIzin = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIzin();
  }

  Future<void> _loadIzin() async {
    setState(() => _loading = true);
    final data = await _controller.fetchIzin();
    if (mounted) {
      setState(() {
        _listIzin = data;
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    final success = await _controller.updateStatusIzin(id, status);
    if (!mounted) return;
    if (success) {
      showFToast(context: context, title: Text('Pengajuan izin berhasil $status'));
      _loadIzin();
    } else {
      showFToast(context: context, title: const Text('Gagal memperbarui status izin'), variant: FToastVariant.destructive);
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
        judul: 'Validasi Izin Mahasiswa',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _listIzin.isEmpty
              ? const Center(child: Text('Tidak ada pengajuan izin pending.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listIzin.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _listIzin[index];
                    return FCard(
                      title: Text(item.pengguna.nama),
                      subtitle: Text('${item.tipeIzin.toUpperCase()} • ${item.tanggal}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Alasan: ${item.alasan}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FButton(
                                variant: FButtonVariant.outline,
                                size: FButtonSizeVariant.sm,
                                onPress: () => _updateStatus(item.id, 'ditolak'),
                                child: const Text('Tolak'),
                              ),
                              const SizedBox(width: 8),
                              FButton(
                                size: FButtonSizeVariant.sm,
                                onPress: () => _updateStatus(item.id, 'disetujui'),
                                child: const Text('Setujui'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
