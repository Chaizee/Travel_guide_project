import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tourist_places.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _keyPrefix = 'cached_places_';
  static const String _lastUpdatePrefix = 'last_update_';

  Future<void> savePlacesForCity(String city, List<TouristPlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$city';
      
      final placesJson = places.map((place) => {
        'title': place.title,
        'subtitle': place.subtitle,
        'imagePath': place.imagePath,
        'address': place.address,
        'description': place.description,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'city': place.city,
        'category': place.category,
        'isFavorite': place.isFavorite,
      }).toList();

      await prefs.setString(key, jsonEncode(placesJson));
      
      final updateKey = '$_lastUpdatePrefix$city';
      await prefs.setInt(updateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
    }
  }

  Future<List<TouristPlace>> loadPlacesForCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$city';
      final placesJsonString = prefs.getString(key);

      if (placesJsonString == null) {
        return [];
      }

      final List<dynamic> placesJson = jsonDecode(placesJsonString);
      final List<TouristPlace> places = [];

      for (var placeData in placesJson) {
        try {
          places.add(TouristPlace(
            title: placeData['title'] ?? '',
            subtitle: placeData['subtitle'] ?? '',
            imagePath: placeData['imagePath'] ?? '',
            address: placeData['address'] ?? '',
            description: placeData['description'] ?? '',
            latitude: (placeData['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (placeData['longitude'] as num?)?.toDouble() ?? 0.0,
            city: placeData['city'] ?? city,
            category: placeData['category'] ?? '',
            isFavorite: placeData['isFavorite'] ?? false,
          ));
        } catch (e) {
          continue;
        }
      }

      return places;
    } catch (e) {
      return [];
    }
  }

  Future<bool> hasCachedDataForCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$city';
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getLastUpdateTime(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updateKey = '$_lastUpdatePrefix$city';
      final timestamp = prefs.getInt(updateKey);
      
      if (timestamp == null) {
        return null;
      }
      
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCacheForCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$city';
      final updateKey = '$_lastUpdatePrefix$city';
      await prefs.remove(key);
      await prefs.remove(updateKey);
    } catch (e) {
    }
  }

  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (var key in keys) {
        if (key.startsWith(_keyPrefix) || key.startsWith(_lastUpdatePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
    }
  }
}

