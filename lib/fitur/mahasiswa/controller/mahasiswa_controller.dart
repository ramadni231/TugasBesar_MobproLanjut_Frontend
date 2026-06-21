import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
// Need a Presensi model eventually, but for now we can use Map or create one
import 'package:tugas_besar/fitur/admin/model/presensi_model.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class MahasiswaController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  List<Jadwal> _jadwal = [];
  List<Jadwal> get jadwal => _jadwal;

  List<Jadwal> _jadwalHariIni = [];
  List<Jadwal> get jadwalHariIni => _jadwalHariIni;

  List<Presensi> _riwayatPresensi = [];
  List<Presensi> get riwayatPresensi => _riwayatPresensi;

  List<Matakuliah> _matakuliahPeminatan = [];
  List<Matakuliah> get matakuliahPeminatan => _matakuliahPeminatan;

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> _getToken() async => await _userSession.getToken();
  Future<Pengguna?> getLoggedInUser() async => await _userSession.getUser();

  Future<void> fetchJadwal() async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/mahasiswa/jadwal', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _jadwal = data.map((json) => Jadwal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Jadwal MHS Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<void> fetchJadwalHariIni({String? tanggal}) async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final url = tanggal != null ? '/mahasiswa/jadwal/hari-ini?tanggal=$tanggal' : '/mahasiswa/jadwal/hari-ini';
      final response = await _apiService.get(url, token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _jadwalHariIni = data.map((json) => Jadwal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Jadwal MHS Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<void> fetchRiwayatPresensi() async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/mahasiswa/presensi/riwayat', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _riwayatPresensi = data.map((json) => Presensi.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Riwayat MHS Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<bool> pindaiPresensi(String tokenQr, double lat, double lng) async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.post('/mahasiswa/presensi/pindai', data: {
        'token_qr': tokenQr,
        'lat': lat,
        'lng': lng,
      }, token: token);
      
      _sedangLoading = false;
      notifyListeners();
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Pindai Presensi Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> batalIzin(int izinId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/mahasiswa/izin/$izinId/batal', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Batal Izin Error: $e');
      return false;
    }
  }

  Future<bool> ajukanIzin({
    required String tipeIzin,
    required String tanggal,
    required String alasan,
    required String lampiranPath,
  }) async {
    _sedangLoading = true;
    notifyListeners();
    try {
      final token = await _getToken();
      final response = await _apiService.postMultipart(
        '/mahasiswa/izin',
        fields: {
          'tipe_izin': tipeIzin,
          'tanggal': tanggal,
          'alasan': alasan,
        },
        fileKey: 'lampiran',
        filePath: lampiranPath,
        token: token,
      );
      
      _sedangLoading = false;
      notifyListeners();
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Ajukan Izin Error: $e');
      _sedangLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMatakuliahPeminatan(int? semester) async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final url = semester != null ? '/mahasiswa/matakuliah?semester=$semester' : '/mahasiswa/matakuliah';
      final response = await _apiService.get(url, token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        _matakuliahPeminatan = data.map((json) => Matakuliah.fromJson(json)).toList();
      } else {
        // Misal 403 Masa peminatan ditutup
        _matakuliahPeminatan = [];
      }
    } catch (e) {
      debugPrint('Fetch Peminatan Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<bool> ajukanPeminatan(int matakuliahId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/mahasiswa/peminatan', data: {
        'matakuliah_id': matakuliahId
      }, token: token);
      
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Ajukan Peminatan Error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchKeranjangPeminatan() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/mahasiswa/peminatan', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('Fetch Keranjang Peminatan Error: $e');
    }
    return [];
  }

  Future<bool> batalPeminatan(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/mahasiswa/peminatan/$id', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Batal Peminatan Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchJadwalDetail(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/mahasiswa/jadwal/$id/detail', token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Fetch Jadwal Detail Error: $e');
    }
    return null;
  }
}
