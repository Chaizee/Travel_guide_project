import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileModel extends ChangeNotifier {
  String _name = 'Гость';
  String _bio = 'Люблю путешествовать';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  ProfileModel() {
    _loadFromPrefs();
  }

  String get name => _name;
  String get bio => _bio;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;

  void setName(String value) {
    _name = value.trim().isEmpty ? 'Гость' : value.trim();
    notifyListeners();
  }

  void setBio(String value) {
    _bio = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
    _saveDarkMode();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> _saveDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _darkModeEnabled);
  }
}


