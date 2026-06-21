import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tugas_besar/umum/utilitas/api_service.dart';
import 'package:tugas_besar/umum/utilitas/user_session.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

enum PeranUser { admin, mahasiswa, dosen }

class OtentikasiController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserSession _userSession = UserSession();

  bool _sedangLoading = false;
  bool get sedangLoading => _sedangLoading;

  Future<String?> login(String identitas, String password) async {
    _sedangLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/login', data: {
        'nomor_identitas': identitas,
        'password': password,
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        final token = data['token'];
        final pengguna = Pengguna.fromJson(data['pengguna']);
        
        await _userSession.saveSession(token, pengguna);
        
        _sedangLoading = false;
        notifyListeners();
        return pengguna.peran; // Return the actual role from DB
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }

    _sedangLoading = false;
    notifyListeners();
    return null; // Return null on failure
  }

  Future<void> logout() async {
    try {
      final token = await _userSession.getToken();
      if (token != null) {
        await _apiService.post('/logout', token: token);
      }
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      await _userSession.clearSession();
    }
  }
}
