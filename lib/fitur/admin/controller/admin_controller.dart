import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';
import 'package:tugas_besar/fitur/admin/model/ruangan_model.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/admin/model/izin_model.dart';

class AdminController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  List<Map<String, dynamic>> _statistik = [];
  List<Map<String, dynamic>> get statistik => _statistik;

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> _getToken() async => await _userSession.getToken();

  Future<void> fetchStatistik() async {
    _sedangLoading = true;
    notifyListeners();

    // Mock statistik based on API fetch users/rooms/schedules
    // In a real app, you might have a specific /api/admin/dashboard endpoint
    try {
      final token = await _getToken();
      final usersRes = await _apiService.get('/admin/pengguna', token: token);
      final roomsRes = await _apiService.get('/admin/ruangan', token: token);
      final schedulesRes = await _apiService.get('/admin/jadwal', token: token);

      if (usersRes.statusCode == 200 && roomsRes.statusCode == 200 && schedulesRes.statusCode == 200) {
        final users = jsonDecode(usersRes.body)['data'] as List;
        final rooms = jsonDecode(roomsRes.body)['data'] as List;
        final schedules = jsonDecode(schedulesRes.body)['data'] as List;

        _statistik = [
          {'label': 'Total Mahasiswa', 'value': users.where((u) => u['peran'] == 'mahasiswa').length.toString()},
          {'label': 'Total Dosen', 'value': users.where((u) => u['peran'] == 'dosen').length.toString()},
          {'label': 'Total Ruangan', 'value': rooms.length.toString()},
          {'label': 'Jadwal Aktif', 'value': schedules.length.toString()},
        ];
      }
    } catch (e) {
      debugPrint('Fetch Statistik Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
  }

  Future<List<Pengguna>> fetchPengguna({String? peran}) async {
    try {
      final token = await _getToken();
      final endpoint = peran != null ? '/admin/pengguna?peran=$peran' : '/admin/pengguna';
      final response = await _apiService.get(endpoint, token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Pengguna.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Pengguna Error: $e');
    }
    return [];
  }

  Future<bool> tambahPengguna(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/pengguna', data: data, token: token);
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Tambah Pengguna Error: $e');
      return false;
    }
  }

  Future<List<Ruangan>> fetchRuangan() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/ruangan', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Ruangan.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Ruangan Error: $e');
    }
    return [];
  }

  Future<List<Matakuliah>> fetchMatakuliah() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/matakuliah', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Matakuliah.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Matakuliah Error: $e');
    }
    return [];
  }

  Future<List<Jadwal>> fetchJadwal() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/jadwal', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Jadwal.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Jadwal Error: $e');
    }
    return [];
  }

  Future<List<Izin>> fetchIzin() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/izin', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => Izin.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Izin Error: $e');
    }
    return [];
  }

  Future<bool> updateStatusIzin(int id, String status) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/izin/$id/status', data: {'status_persetujuan': status}, token: token); // Note: Should use PUT ideally but following my controller logic
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Izin Error: $e');
      return false;
    }
  }
}
