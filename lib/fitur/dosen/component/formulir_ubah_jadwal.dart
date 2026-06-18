import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class FormulirUbahJadwal extends StatelessWidget {
  const FormulirUbahJadwal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FTextField(
          label: Text('Tanggal Baru'),
          hint: 'YYYY-MM-DD',
        ),
        const SizedBox(height: 16),
        const FTextField(
          label: Text('Waktu Baru'),
          hint: 'HH:MM',
        ),
        const SizedBox(height: 16),
        FSelect<String>.rich(
          label: const Text('Ruangan'),
          hint: 'Pilih Ruangan',
          format: (v) => v,
          children: [
            .item(title: const Text('Lab 1'), value: 'Lab 1'),
            .item(title: const Text('Ruang 3.1'), value: 'Ruang 3.1'),
          ],
        ),
      ],
    );
  }
}
