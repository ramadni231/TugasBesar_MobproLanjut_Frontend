import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/component/formulir_jadwal.dart';

class ManajemenJadwal extends StatefulWidget {
  const ManajemenJadwal({super.key});

  @override
  State<ManajemenJadwal> createState() => _ManajemenJadwalState();
}

class _ManajemenJadwalState extends State<ManajemenJadwal> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(title: Text('Pembuatan Jadwal')),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FCard(
              title: const Text('Buat Jadwal Baru'),
              subtitle: const Text('Silakan lengkapi detail jadwal perkuliahan.'),
              child: const FormulirJadwal(),
            ),

            const SizedBox(height: 24),
            FButton(
              onPress: () => showFToast(
                context: context,
                title: const Text('Jadwal Berhasil Disimpan'),
              ),
              child: const Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}
