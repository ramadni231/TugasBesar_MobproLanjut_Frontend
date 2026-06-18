import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class Izin {
  final int id;
  final Pengguna pengguna;
  final String tipeIzin;
  final String tanggal;
  final String alasan;
  final String jalurLampiran;
  final String statusPersetujuan;
  final Pengguna? disetujuiOleh;

  Izin({
    required this.id,
    required this.pengguna,
    required this.tipeIzin,
    required this.tanggal,
    required this.alasan,
    required this.jalurLampiran,
    required this.statusPersetujuan,
    this.disetujuiOleh,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      id: json['id'],
      pengguna: Pengguna.fromJson(json['pengguna']),
      tipeIzin: json['tipe_izin'],
      tanggal: json['tanggal'],
      alasan: json['alasan'],
      jalurLampiran: json['jalur_lampiran'],
      statusPersetujuan: json['status_persetujuan'],
      disetujuiOleh: json['disetujui_oleh'] != null ? Pengguna.fromJson(json['disetujui_oleh']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengguna': pengguna.toJson(),
      'tipe_izin': tipeIzin,
      'tanggal': tanggal,
      'alasan': alasan,
      'jalur_lampiran': jalurLampiran,
      'status_persetujuan': statusPersetujuan,
      'disetujui_oleh': disetujuiOleh?.toJson(),
    };
  }
}
