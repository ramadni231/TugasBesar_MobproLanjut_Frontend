import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ValidasiIzinGlobal extends StatelessWidget {
  const ValidasiIzinGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(title: Text('Validasi Izin (Global)')),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return FCard(
            title: Text('Pengajuan #${1000 + index}'),
            subtitle: const Text('Mahasiswa Informatika • Pending'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Jenis: Izin Keluarga'),
                const Text('Tanggal: 29 Okt 2023'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      onPress: () => showFToast(context: context, title: const Text('Ditolak oleh Admin')),
                      child: const Text('Tolak'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      size: FButtonSizeVariant.sm,
                      onPress: () => showFToast(context: context, title: const Text('Disetujui oleh Admin')),
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
