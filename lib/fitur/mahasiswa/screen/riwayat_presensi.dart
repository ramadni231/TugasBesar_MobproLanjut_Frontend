import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/kartu_riwayat.dart';

class RiwayatPresensi extends StatefulWidget {
  const RiwayatPresensi({super.key});

  @override
  State<RiwayatPresensi> createState() => _RiwayatPresensiState();
}

class _RiwayatPresensiState extends State<RiwayatPresensi> {
  final _controller = MahasiswaController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _controller.fetchRiwayatPresensi();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(
        title: Text('Riwayat Presensi'),
      ),
      child: _controller.sedangLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.riwayatPresensi.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final presensi = _controller.riwayatPresensi[index];
              return KartuRiwayat(
                matakuliah: presensi.jadwal.matakuliah.namaMatkul,
                tanggal: '${presensi.tanggal} • ${presensi.jamMasuk ?? "-"}',
                status: presensi.status.toUpperCase(),
                isHadir: presensi.status == 'hadir',
              );
            },
          ),
    );
  }
}
