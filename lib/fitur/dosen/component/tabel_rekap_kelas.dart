import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TabelRekapKelas extends StatelessWidget {
  const TabelRekapKelas({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Mahasiswa Hadir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              onPress: () => showFToast(context: context, title: const Text('Mengekspor Data...')),
              child: const Row(
                children: [
                  Icon(FIcons.download, size: 14),
                  SizedBox(width: 4),
                  Text('Ekspor'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FCard(
                title: Text('Mahasiswa ${index + 1}'),
                subtitle: const Text('220101000 • 08:05'),
                child: const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }
}
