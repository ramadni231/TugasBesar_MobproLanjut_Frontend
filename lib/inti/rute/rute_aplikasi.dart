import 'package:flutter/material.dart';
import 'package:tugas_besar/fitur/otentikasi/screen/screen_masuk.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_pengguna.dart';
import 'package:tugas_besar/fitur/admin/screen/dasbor_admin.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_ruangan.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_matkul.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_jadwal.dart';
import 'package:tugas_besar/fitur/admin/screen/rekap_presensi_global.dart';
import 'package:tugas_besar/fitur/admin/screen/validasi_izin_global.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/dasbor_mahasiswa.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/jadwal_mahasiswa.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/detail_jadwal_mahasiswa.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/pemindai_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/riwayat_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/pengajuan_izin.dart';
import 'package:tugas_besar/fitur/dosen/screen/dasbor_dosen.dart';
import 'package:tugas_besar/fitur/dosen/screen/jadwal_mengajar.dart';
import 'package:tugas_besar/fitur/dosen/screen/detail_kelas_aktif.dart';
import 'package:tugas_besar/fitur/dosen/screen/validasi_izin.dart';

import 'package:tugas_besar/fitur/otentikasi/screen/splash_screen.dart';

class RuteAplikasi {
  static const String splash = '/splash';
  static const String masuk = '/';
  
  static const String admin = '/admin';
  static const String adminPengguna = '/admin/pengguna';
  static const String adminRuangan = '/admin/ruangan';
  static const String adminMatkul = '/admin/matkul';
  static const String adminJadwal = '/admin/jadwal';
  static const String adminRekap = '/admin/rekap';
  static const String adminValidasi = '/admin/validasi';

  static const String mahasiswa = '/mahasiswa';
  static const String mahasiswaJadwal = '/mahasiswa/jadwal';
  static const String mahasiswaJadwalDetail = '/mahasiswa/jadwal/detail';
  static const String mahasiswaScan = '/mahasiswa/scan';
  static const String mahasiswaRiwayat = '/mahasiswa/riwayat';
  static const String mahasiswaIzin = '/mahasiswa/izin';

  static const String dosen = '/dosen';
  static const String dosenJadwal = '/dosen/jadwal';
  static const String dosenDetail = '/dosen/detail';
  static const String dosenValidasi = '/dosen/validasi';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    masuk: (context) => const ScreenMasuk(),
    
    admin: (context) => const DasborAdmin(),
    adminPengguna: (context) => const ManajemenPengguna(),
    adminRuangan: (context) => const ManajemenRuangan(),
    adminMatkul: (context) => const ManajemenMatkul(),
    adminJadwal: (context) => const ManajemenJadwal(),
    adminRekap: (context) => const RekapPresensi(),
    adminValidasi: (context) => const ValidasiIzinAdmin(),

    mahasiswa: (context) => const DasborMahasiswa(),
    mahasiswaJadwal: (context) => const JadwalMahasiswa(),
    mahasiswaJadwalDetail: (context) => const DetailJadwalMahasiswa(),
    mahasiswaScan: (context) => const PemindaiPresensi(),
    mahasiswaRiwayat: (context) => const RiwayatPresensi(),
    mahasiswaIzin: (context) => const PengajuanIzin(),

    dosen: (context) => const DasborDosen(),
    dosenJadwal: (context) => const JadwalMengajar(),
    dosenDetail: (context) => const DetailKelasAktif(matakuliah: 'Pemrograman Mobile'),
    dosenValidasi: (context) => const ValidasiIzinDosen(),
  };
}
