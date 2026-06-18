import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class FormulirJadwal extends StatelessWidget {
  const FormulirJadwal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FSelect<String>.rich(
          label: const Text('Mata Kuliah'),
          hint: 'Pilih Matkul',
          format: (v) => v,
          children: [
            .item(title: const Text('Pemrograman Mobile'), value: 'Pemrograman Mobile'),
            .item(title: const Text('Basis Data'), value: 'Basis Data'),
          ],
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
        const SizedBox(height: 16),
        const FTextField(
          label: Text('Waktu Mulai'),
          hint: '08:00',
        ),
        const SizedBox(height: 16),
        const FTextField(
          label: Text('Waktu Selesai'),
          hint: '10:30',
        ),
      ],
    );
  }
}
