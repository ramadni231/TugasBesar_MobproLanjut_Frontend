import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ValidasiIzin extends StatelessWidget {
  const ValidasiIzin({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(title: Text('Validasi Izin Mahasiswa')),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return FCard(
            title: Text('Mahasiswa ${index + 1}'),
            subtitle: const Text('Izin Sakit • 28 Okt 2023'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Alasan: Badan demam tinggi mohon izin tidak ikut kuliah.'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      onPress: () => showFToast(context: context, title: const Text('Izin Ditolak')),
                      child: const Text('Tolak'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      size: FButtonSizeVariant.sm,
                      onPress: () => showFToast(context: context, title: const Text('Izin Disetujui')),
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
