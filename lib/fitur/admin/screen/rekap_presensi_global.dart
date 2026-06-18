import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class RekapPresensiGlobal extends StatelessWidget {
  const RekapPresensiGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(
        title: Text('Rekap Presensi Global'),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return FCard(
            title: Text('Mahasiswa ${index + 1}'),
            subtitle: const Text('NIM: 220101000 • Informatika'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kehadiran: 90%'),
                FButton(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  onPress: () {},
                  child: const Text('Detail'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
