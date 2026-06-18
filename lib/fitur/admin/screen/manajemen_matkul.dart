import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ManajemenMatkul extends StatefulWidget {
  const ManajemenMatkul({super.key});

  @override
  State<ManajemenMatkul> createState() => _ManajemenMatkulState();
}

class _ManajemenMatkulState extends State<ManajemenMatkul> {
  final List<Map<String, String>> _matkul = [
    {'kode': 'IF101', 'nama': 'Pemrograman Mobile'},
    {'kode': 'IF102', 'nama': 'Basis Data'},
    {'kode': 'IF103', 'nama': 'Kecerdasan Buatan'},
    {'kode': 'IF104', 'nama': 'Jaringan Komputer'},
  ];

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Manajemen Mata Kuliah'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.plus),
            onPress: () => showFToast(context: context, title: const Text('Tambah Matkul')),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _matkul.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _matkul[index];
          return FCard(
            title: Text(item['nama']!),
            subtitle: Text('Kode: ${item['kode']} • 3 SKS'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Ubah ${item['nama']}')),
                  child: const Icon(FIcons.pencil, size: 16),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: () => showFToast(context: context, title: Text('Hapus ${item['nama']}')),
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
