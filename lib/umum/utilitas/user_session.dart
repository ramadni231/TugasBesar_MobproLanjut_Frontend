import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  SharedPreferences? _prefs;

  UserSession._internal();

  Future<void> saveSession(String token, Pengguna pengguna) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_keyToken, token);
    await _prefs?.setString(_keyUser, jsonEncode(pengguna.toJson()));
  }

  Future<String?> getToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(_keyToken);
  }

  Future<Pengguna?> getUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    String? userJson = _prefs?.getString(_keyUser);
    if (userJson != null) {
      return Pengguna.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearSession() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }
}
