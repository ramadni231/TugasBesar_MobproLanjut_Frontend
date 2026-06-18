import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class DialogBatalKelas extends StatelessWidget {
  final String matakuliah;
  final VoidCallback onKonfirmasi;

  const DialogBatalKelas({
    super.key,
    required this.matakuliah,
    required this.onKonfirmasi,
  });

  @override
  Widget build(BuildContext context) {
    return FDialog(
      direction: Axis.vertical,
      title: const Text('Batalkan Kelas?'),
      body: Text('Apakah anda yakin ingin membatalkan kelas $matakuliah? Mahasiswa akan mendapatkan notifikasi.'),
      actions: [
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () {
            onKonfirmasi();
            Navigator.pop(context);
          },
          child: const Text('Ya, Batalkan'),
        ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.pop(context),
          child: const Text('Kembali'),
        ),
      ],
    );
  }
}
