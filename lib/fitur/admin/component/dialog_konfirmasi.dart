import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class DialogKonfirmasi extends StatelessWidget {
  final String judul;
  final String pesan;
  final String teksKonfirmasi;
  final VoidCallback onKonfirmasi;

  const DialogKonfirmasi({
    super.key,
    required this.judul,
    required this.pesan,
    this.teksKonfirmasi = 'Hapus',
    required this.onKonfirmasi,
  });

  @override
  Widget build(BuildContext context) {
    return FDialog(
      direction: Axis.horizontal,
      title: Text(judul),
      body: Text(pesan),
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          child: const Text('Batal'),
          onPress: () => Navigator.of(context).pop(),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          child: Text(teksKonfirmasi),
          onPress: () {
            onKonfirmasi();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

Future<void> tampilkanKonfirmasiHapus({
  required BuildContext context,
  required String item,
  required VoidCallback onHapus,
}) {
  return showFDialog(
    context: context,
    builder: (context, style, animation) => DialogKonfirmasi(
      judul: 'Konfirmasi Hapus',
      pesan: 'Apakah Anda yakin ingin menghapus $item? Tindakan ini tidak dapat dibatalkan.',
      onKonfirmasi: onHapus,
    ),
  );
}
