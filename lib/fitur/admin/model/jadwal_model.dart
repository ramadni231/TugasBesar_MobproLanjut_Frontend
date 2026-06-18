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

  Jadwal({
    required this.id,
    required this.matakuliah,
    required this.ruangan,
    required this.dosen,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
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
    };
  }
}
