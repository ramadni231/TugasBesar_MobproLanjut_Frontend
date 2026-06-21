import 'package:tugas_besar/fitur/admin/model/ruangan_model.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class Jadwal {
  final int id;
  final Matakuliah matakuliah;
  final Ruangan ruangan;
  final Pengguna dosen;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String metode; // luring or daring
  final SesiAktif? sesiAktif;
  final int hadirCount;

  Jadwal({
    required this.id,
    required this.matakuliah,
    required this.ruangan,
    required this.dosen,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.metode,
    this.sesiAktif,
    this.hadirCount = 0,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'],
      matakuliah: Matakuliah.fromJson(json['matakuliah']),
      ruangan: Ruangan.fromJson(json['ruangan']),
      dosen: Pengguna.fromJson(json['dosen']),
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      metode: json['metode'] ?? 'luring',
      sesiAktif: json['sesi_aktif'] != null ? SesiAktif.fromJson(json['sesi_aktif']) : null,
      hadirCount: json['presensi_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matakuliah': matakuliah.toJson(),
      'ruangan': ruangan.toJson(),
      'dosen': dosen.toJson(),
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'metode': metode,
      'sesi_aktif': sesiAktif?.toJson(),
      'presensi_count': hadirCount,
    };
  }
}

class SesiAktif {
  final int id;
  final int jadwalId;
  final String tokenQr;
  final DateTime berakhirPada;
  final bool isAktif;
  final int pertemuanKe;

  SesiAktif({
    required this.id,
    required this.jadwalId,
    required this.tokenQr,
    required this.berakhirPada,
    required this.isAktif,
    required this.pertemuanKe,
  });

  factory SesiAktif.fromJson(Map<String, dynamic> json) {
    return SesiAktif(
      id: json['id'],
      jadwalId: json['jadwal_id'],
      tokenQr: json['token_qr'],
      berakhirPada: DateTime.parse(json['berakhir_pada']),
      isAktif: json['is_aktif'] is int ? json['is_aktif'] == 1 : (json['is_aktif'] ?? false),
      pertemuanKe: json['pertemuan_ke'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jadwal_id': jadwalId,
      'token_qr': tokenQr,
      'berakhir_pada': berakhirPada.toIso8601String(),
      'is_aktif': isAktif,
      'pertemuan_ke': pertemuanKe,
    };
  }
}
