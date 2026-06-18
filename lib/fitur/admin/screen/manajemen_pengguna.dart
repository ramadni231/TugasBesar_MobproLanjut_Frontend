import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ManajemenPengguna extends StatefulWidget {
  const ManajemenPengguna({super.key});

  @override
  State<ManajemenPengguna> createState() => _ManajemenPenggunaState();
}

class _ManajemenPenggunaState extends State<ManajemenPengguna> {
  final List<Map<String, String>> _users = [
    {'nama': 'Andrean Syah Putra', 'identitas': 'STI202303719', 'peran': 'Mahasiswa'},
    {'nama': 'Fani Amalia Riswati', 'identitas': 'STI202303720', 'peran': 'Mahasiswa'},
    {'nama': 'Turiman', 'identitas': '198001012010011001', 'peran': 'Dosen'},
  ];

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => FDialog(
        title: const Text('Tambah Pengguna'),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextField(
              label: const Text('Nama Lengkap'),
              hint: 'Masukkan nama',
            ),
            const SizedBox(height: 16),
            FTextField(
              label: const Text('NIM/NIP'),
              hint: 'Masukkan identitas',
            ),
            const SizedBox(height: 16),
            FSelect<String>.rich(
              label: const Text('Peran'),
              hint: 'Pilih Peran',
              format: (v) => v,
              children: [
                .item(title: const Text('Mahasiswa'), value: 'Mahasiswa'),
                .item(title: const Text('Dosen'), value: 'Dosen'),
              ],
            ),
          ],
        ),
        actions: [
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FButton(
            onPress: () {
              showFToast(context: context, title: const Text('Pengguna Berhasil Ditambahkan'));
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Manajemen Pengguna'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: _showAddUserDialog,
          ),
          FHeaderAction(
            icon: const Icon(FIcons.download),
            onPress: () => showFToast(context: context, title: const Text('Mengekspor Akun...')),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
          return FCard(
            title: Text(user['nama']!),
            subtitle: Text('${user['identitas']} • ${user['peran']}'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton.icon(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Edit ${user['nama']}')),
                  child: const Icon(FIcons.pencil, size: 16),
                ),
                const SizedBox(width: 8),
                FButton.icon(
                  variant: FButtonVariant.destructive,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Hapus ${user['nama']}')),
                  child: const Icon(FIcons.trash2, size: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
