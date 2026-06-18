import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/admin/model/izin_model.dart';
import 'package:tugas_besar/fitur/admin/model/presensi_model.dart';

class DosenController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  List<Jadwal> _jadwalMengajar = [];
  List<Jadwal> get jadwalMengajar => _jadwalMengajar;

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> _getToken() async => await _userSession.getToken();

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

  Future<Map<String, dynamic>?> aktifkanSesi(int jadwalId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/dosen/sesi/aktifkan', data: {'jadwal_id': jadwalId}, token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Aktifkan Sesi Error: $e');
    }
    return null;
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
      final response = await _apiService.post('/dosen/izin/$id/status', data: {'status_persetujuan': status}, token: token);
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
}
