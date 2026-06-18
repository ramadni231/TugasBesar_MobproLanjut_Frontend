import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class Presensi {
  final int id;
  final Jadwal jadwal;
  final Pengguna mahasiswa;
  final String tanggal;
  final String? jamMasuk;
  final String status;
  final double? latScan;
  final double? lngScan;

  Presensi({
    required this.id,
    required this.jadwal,
    required this.mahasiswa,
    required this.tanggal,
    this.jamMasuk,
    required this.status,
    this.latScan,
    this.lngScan,
  });

  factory Presensi.fromJson(Map<String, dynamic> json) {
    return Presensi(
      id: json['id'],
      jadwal: Jadwal.fromJson(json['jadwal']),
      mahasiswa: Pengguna.fromJson(json['mahasiswa']),
      tanggal: json['tanggal'],
      jamMasuk: json['jam_masuk'],
      status: json['status'],
      latScan: json['lat_scan']?.toDouble(),
      lngScan: json['lng_scan']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jadwal': jadwal.toJson(),
      'mahasiswa': mahasiswa.toJson(),
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'status': status,
      'lat_scan': latScan,
      'lng_scan': lngScan,
    };
  }
}
