import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';
import 'package:tugas_besar/fitur/admin/component/modal_form_pengguna.dart';
import 'package:tugas_besar/fitur/admin/component/dialog_konfirmasi.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class ManajemenPengguna extends StatefulWidget {
  const ManajemenPengguna({super.key});

  @override
  State<ManajemenPengguna> createState() => _ManajemenPenggunaState();
}

class _ManajemenPenggunaState extends State<ManajemenPengguna> {
  final _controller = AdminController();
  List<Pengguna> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final data = await _controller.fetchPengguna();
      setState(() {
        _users = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _tambahPengguna() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormPengguna(
        onSubmit: (data) async {
          final error = await _controller.tambahPengguna(data);
          if (!mounted) return;
          if (error == null) {
            _loadUsers();
            showFToast(context: context, title: const Text('Pengguna berhasil ditambahkan'));
          } else {
            showFToast(context: context, title: Text(error), variant: FToastVariant.destructive);
          }
        },
      ),
    );
  }

  void _editPengguna(Pengguna pengguna) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormPengguna(
        pengguna: pengguna,
        onSubmit: (data) async {
          final error = await _controller.updatePengguna(pengguna.id, data);
          if (!mounted) return;
          if (error == null) {
            _loadUsers();
            showFToast(context: context, title: const Text('Pengguna berhasil diperbarui'));
          } else {
            showFToast(context: context, title: Text(error), variant: FToastVariant.destructive);
          }
        },
      ),
    );
  }

  void _hapusPengguna(Pengguna pengguna) {
    tampilkanKonfirmasiHapus(
      context: context,
      item: pengguna.nama,
      onHapus: () async {
        final success = await _controller.hapusPengguna(pengguna.id);
        if (!mounted) return;
        if (success) {
          _loadUsers();
          showFToast(context: context, title: const Text('Pengguna berhasil dihapus'));
        } else {
          showFToast(context: context, title: const Text('Gagal menghapus pengguna'), variant: FToastVariant.destructive);
        }
      },
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
        judul: 'Manajemen Pengguna',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahPengguna,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('Tidak ada pengguna terdaftar.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = _users[index];
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
                              user.nama,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.nomorIdentitas} • ${user.peran.toUpperCase()}\n${user.email}',
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
                                  onPress: () => _editPengguna(user),
                                  child: const Icon(FIcons.pencil, size: 16),
                                ),
                                const SizedBox(width: 8),
                                FButton.icon(
                                  variant: FButtonVariant.destructive,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => _hapusPengguna(user),
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
