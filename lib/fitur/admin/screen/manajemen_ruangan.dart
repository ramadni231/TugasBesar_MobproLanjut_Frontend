import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ManajemenRuangan extends StatefulWidget {
  const ManajemenRuangan({super.key});

  @override
  State<ManajemenRuangan> createState() => _ManajemenRuanganState();
}

class _ManajemenRuanganState extends State<ManajemenRuangan> {
  final List<String> _ruangan = ['Lab 1', 'Lab 2', 'Ruang 3.1', 'Ruang 3.2', 'Aula Utama'];

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Manajemen Ruangan'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => showFToast(context: context, title: const Text('Tambah Ruangan')),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _ruangan.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _ruangan[index];
          return FCard(
            title: Text(item),
            subtitle: const Text('Fakultas Teknik • Lantai 3'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Ubah $item')),
                  child: const Icon(FIcons.pencil, size: 16),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Hapus $item')),
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
