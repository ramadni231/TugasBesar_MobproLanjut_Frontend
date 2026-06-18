import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KontrolerTema extends ChangeNotifier {
  static final KontrolerTema _instance = KontrolerTema._internal();
  factory KontrolerTema() => _instance;

  static const String _key = 'is_dark_mode';
  SharedPreferences? _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  KontrolerTema._internal() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_key, _isDarkMode);
    notifyListeners();
  }
}
