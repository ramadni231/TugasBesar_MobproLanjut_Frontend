import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/indikator_gps.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/kotak_kamera_pemindai.dart';

class PemindaiPresensi extends StatefulWidget {
  const PemindaiPresensi({super.key});

  @override
  State<PemindaiPresensi> createState() => _PemindaiPresensiState();
}

class _PemindaiPresensiState extends State<PemindaiPresensi> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(
        title: Text('Scan Presensi'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const IndikatorGps(dalamRadius: true, jarak: 12.5),
            const SizedBox(height: 24),
            const KotakKameraPemindai(),
            const SizedBox(height: 24),
            FCard(
              title: const Text('Instruksi'),
              subtitle: const Text('Posisikan QR Code di dalam kotak pemindai.'),
              child: FButton(
                onPress: () => showFToast(context: context, title: const Text('Presensi Berhasil')),
                child: const Text('Simulasi Scan Sukses'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
