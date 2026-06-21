import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/admin/model/izin_model.dart';
import 'package:tugas_besar/fitur/admin/model/presensi_model.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class DosenController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  List<Jadwal> _jadwalMengajar = [];
  List<Jadwal> get jadwalMengajar => _jadwalMengajar;

  List<Jadwal> _kelasHariIni = [];
  List<Jadwal> get kelasHariIni => _kelasHariIni;

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> _getToken() async => await _userSession.getToken();
  Future<Pengguna?> getLoggedInUser() async => await _userSession.getUser();

  Future<void> fetchJadwal() async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/jadwal', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _jadwalMengajar = data.map((json) => Jadwal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Jadwal Dosen Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<void> fetchKelasHariIni({String? tanggal}) async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final url = tanggal != null ? '/dosen/jadwal/hari-ini?tanggal=$tanggal' : '/dosen/jadwal/hari-ini';
      final response = await _apiService.get(url, token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _kelasHariIni = data.map((json) => Jadwal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Kelas Hari Ini Dosen Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> aktifkanSesi(int jadwalId, {int? pertemuanKe}) async {
    try {
      final token = await _getToken();
      final data = <String, dynamic>{'jadwal_id': jadwalId};
      if (pertemuanKe != null) {
        data['pertemuan_ke'] = pertemuanKe;
      }
      final response = await _apiService.post('/dosen/sesi/aktifkan', data: data, token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Aktifkan Sesi Error: $e');
    }
    return null;
  }

  Future<bool> rescheduleJadwal(int jadwalId, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/dosen/jadwal/$jadwalId/reschedule', data: data, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reschedule Error: $e');
      return false;
    }
  }

  Future<bool> hentikanSesi(int sesiId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/dosen/sesi/$sesiId/hentikan', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Hentikan Sesi Error: $e');
      return false;
    }
  }

  Future<List<Izin>> fetchIzin() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/izin', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Izin.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Izin Dosen Error: $e');
    }
    return [];
  }

  Future<bool> updateStatusIzin(int id, String status) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/dosen/izin/$id/status', data: {'status_persetujuan': status}, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Izin Dosen Error: $e');
      return false;
    }
  }

  Future<List<Presensi>> fetchPresensiRealtime(int jadwalId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/sesi/$jadwalId/presensi', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Presensi.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Presensi Realtime Error: $e');
    }
    return [];
  }

  Future<List<SesiAktif>> fetchRiwayatSesi(int jadwalId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/riwayat/jadwal/$jadwalId', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => SesiAktif.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Riwayat Sesi Error: $e');
    }
    return [];
  }

  Future<List<Presensi>> fetchPresensiSesi(int jadwalId, int pertemuanKe) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/riwayat/jadwal/$jadwalId/pertemuan/$pertemuanKe', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Presensi.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Presensi Sesi Error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchJadwalDetail(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/dosen/jadwal/$id/detail', token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Fetch Jadwal Detail Error: $e');
    }
    return null;
  }

  Future<bool> updatePresensiManual(int jadwalId, int pertemuanKe, int mahasiswaId, String status) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post(
        '/dosen/presensi/manual',
        data: {
          'jadwal_id': jadwalId,
          'pertemuan_ke': pertemuanKe,
          'mahasiswa_id': mahasiswaId,
          'status': status,
        },
        token: token,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Presensi Manual Error: $e');
      return false;
    }
  }
}
