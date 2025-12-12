import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tourist_places.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _keyPrefix = 'cached_places_';
  static const String _lastUpdatePrefix = 'last_update_';

  Future<List<TouristPlace>> loadPlacesForCity(String city) async {
    return [];
  }

  Future<bool> hasCachedDataForCity(String city) async {
    return false;
  }

  Future<List<String>> getCachedCities() async {
    return [];
  }

  Future<DateTime?> getLastUpdateTime(String city) async {
    return null;
  }

}

