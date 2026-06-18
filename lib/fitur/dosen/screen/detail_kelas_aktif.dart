import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/dosen/component/tabel_rekap_kelas.dart';

class DetailKelasAktif extends StatefulWidget {
  final String matakuliah;

  const DetailKelasAktif({
    super.key,
    required this.matakuliah,
  });

  @override
  State<DetailKelasAktif> createState() => _DetailKelasAktifState();
}

class _DetailKelasAktifState extends State<DetailKelasAktif> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: Text(widget.matakuliah),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FCard(
              title: const Text('Status Presensi'),
              subtitle: const Text('Dibuka sejak 08:00'),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    '25 / 30',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text('Mahasiswa Hadir'),
                  const SizedBox(height: 16),
                  FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () => Navigator.pop(context),
                    child: const Text('Tutup Presensi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const TabelRekapKelas(),
          ],
        ),
      ),
    );
  }
}
