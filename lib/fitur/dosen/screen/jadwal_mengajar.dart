import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class JadwalMengajar extends StatelessWidget {
  const JadwalMengajar({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(
        title: Text('Jadwal Mengajar'),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'][index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hari,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              FCard(
                title: const Text('Pemrograman Mobile'),
                subtitle: const Text('08:00 - 10:30 • Lab 1'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      onPress: () => showFToast(context: context, title: const Text('Ubah Jadwal')),
                      child: const Text('Reschedule'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
