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
  Future<Pengguna?> getLoggedInUser() async => await _userSession.getUser();

  /// Kembalikan true jika response menandakan token expired / tidak valid.
  bool _isUnauthorized(int statusCode) => statusCode == 401 || statusCode == 403;

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

  Future<String?> tambahPengguna(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/pengguna', data: data, token: token);
      if (response.statusCode == 201) {
        return null;
      } else {
        try {
          final resBody = jsonDecode(response.body);
          if (resBody['errors'] != null && resBody['errors'] is Map) {
            final errors = resBody['errors'] as Map;
            final List<String> messages = [];
            errors.forEach((key, value) {
              if (value is List) {
                messages.add(value.join(', '));
              } else {
                messages.add(value.toString());
              }
            });
            return messages.join('\n');
          }
          return resBody['message'] ?? 'Gagal menambahkan pengguna';
        } catch (_) {
          return 'Gagal menambahkan pengguna (Status: ${response.statusCode})';
        }
      }
    } catch (e) {
      debugPrint('Tambah Pengguna Error: $e');
      return e.toString();
    }
  }

  Future<bool> hapusPengguna(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/admin/pengguna/$id', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Hapus Pengguna Error: $e');
      return false;
    }
  }

  Future<String?> updatePengguna(int id, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/admin/pengguna/$id', data: data, token: token);
      if (response.statusCode == 200) {
        return null;
      } else {
        try {
          final resBody = jsonDecode(response.body);
          if (resBody['errors'] != null && resBody['errors'] is Map) {
            final errors = resBody['errors'] as Map;
            final List<String> messages = [];
            errors.forEach((key, value) {
              if (value is List) {
                messages.add(value.join(', '));
              } else {
                messages.add(value.toString());
              }
            });
            return messages.join('\n');
          }
          return resBody['message'] ?? 'Gagal memperbarui pengguna';
        } catch (_) {
          return 'Gagal memperbarui pengguna (Status: ${response.statusCode})';
        }
      }
    } catch (e) {
      debugPrint('Update Pengguna Error: $e');
      return e.toString();
    }
  }

  // --- RUANGAN ---
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

  Future<bool> tambahRuangan(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/ruangan', data: data, token: token);
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Tambah Ruangan Error: $e');
      return false;
    }
  }

  Future<bool> updateRuangan(int id, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/admin/ruangan/$id', data: data, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Ruangan Error: $e');
      return false;
    }
  }

  Future<bool> hapusRuangan(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/admin/ruangan/$id', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Hapus Ruangan Error: $e');
      return false;
    }
  }

  // --- MATAKULIAH ---
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

  Future<bool> tambahMatakuliah(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/matakuliah', data: data, token: token);
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Tambah Matakuliah Error: $e');
      return false;
    }
  }

  Future<bool> updateMatakuliah(int id, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/admin/matakuliah/$id', data: data, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Matakuliah Error: $e');
      return false;
    }
  }

  Future<bool> hapusMatakuliah(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/admin/matakuliah/$id', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Hapus Matakuliah Error: $e');
      return false;
    }
  }

  // --- JADWAL ---
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

  Future<bool> tambahJadwal(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/jadwal', data: data, token: token);
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Tambah Jadwal Error: $e');
      return false;
    }
  }

  Future<bool> updateJadwal(int id, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/admin/jadwal/$id', data: data, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Jadwal Error: $e');
      return false;
    }
  }

  Future<bool> hapusJadwal(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.delete('/admin/jadwal/$id', token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Hapus Jadwal Error: $e');
      return false;
    }
  }

  // --- IZIN ---
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
      final response = await _apiService.put('/admin/izin/$id/status', data: {'status_persetujuan': status}, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Izin Error: $e');
      return false;
    }
  }

  // --- PEMINATAN ---
  Future<bool> toggleMasaPeminatan(bool isAktif) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/admin/pengaturan/peminatan', data: {'is_aktif': isAktif}, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Toggle Peminatan Error: $e');
      return false;
    }
  }

  Future<bool> updateStatusPeminatan(int id, String status) async {
    try {
      final token = await _getToken();
      final response = await _apiService.put('/admin/peminatan/$id/status', data: {'status': status}, token: token);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Peminatan Error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPeminatan() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/peminatan', token: token);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('Fetch Peminatan Error: $e');
    }
    return [];
  }

  Future<bool> getPeminatanStatus() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/pengaturan/peminatan', token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['is_aktif'];
      }
    } catch (e) {
      debugPrint('Get Peminatan Status Error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> fetchJadwalRekap(int id) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/jadwal/$id/rekap', token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Fetch Jadwal Rekap Error: $e');
    }
    return null;
  }

  Future<String> fetchTanggalMulaiSemester() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/admin/pengaturan/mulai-semester', token: token);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']['nilai'];
      }
    } catch (e) {
      debugPrint('Fetch Tanggal Mulai Semester Error: $e');
    }
    return '2026-02-23';
  }

  Future<bool> setTanggalMulaiSemester(String tanggal) async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Set Tanggal Mulai Semester: token null, sesi tidak valid');
        return false;
      }
      final response = await _apiService.post(
        '/admin/pengaturan/mulai-semester',
        data: {'tanggal': tanggal},
        token: token,
      );
      debugPrint('Set Tanggal Mulai Semester: HTTP ${response.statusCode} — ${response.body}');
      if (_isUnauthorized(response.statusCode)) {
        // Token expired / tidak valid — hapus sesi agar user login ulang
        await _userSession.clearSession();
        throw Exception('SESSION_EXPIRED');
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Set Tanggal Mulai Semester Error: $e');
      rethrow;
    }
  }
}
