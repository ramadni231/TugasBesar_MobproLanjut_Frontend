import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
// Need a Presensi model eventually, but for now we can use Map or create one
import 'package:tugas_besar/fitur/admin/model/presensi_model.dart'; 

class MahasiswaController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  List<Jadwal> _jadwalHariIni = [];
  List<Jadwal> get jadwalHariIni => _jadwalHariIni;

  List<Presensi> _riwayatPresensi = [];
  List<Presensi> get riwayatPresensi => _riwayatPresensi;

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> _getToken() async => await _userSession.getToken();

  Future<void> fetchJadwalHariIni() async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _apiService.get('/mahasiswa/jadwal/hari-ini', token: token);
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
}
