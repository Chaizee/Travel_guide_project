import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/tourist_places.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  bool get isInitialized {
    try {
      final _ = Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TouristPlace>> loadPlacesForCity(String city) async {
    if (!isInitialized) {
      debugPrint('SupabaseService: Supabase не инициализирован');
      return [];
    }

    try {
      debugPrint('SupabaseService: Загрузка мест для города: $city');
      final response = await client
          .from('places')
          .select()
          .eq('city', city)
          .order('title');

      debugPrint('SupabaseService: Получено ${response.length} записей из базы данных');
      
      final List<TouristPlace> places = [];
      for (var row in response) {
        try {
          places.add(TouristPlace(
            title: row['title'] ?? '',
            subtitle: row['subtitle'] ?? '',
            imagePath: row['image_path'] ?? '',
            address: row['address'] ?? '',
            description: row['description'] ?? '',
            latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
            city: row['city'] ?? city,
            category: row['category'] ?? '',
            isFavorite: false,
          ));
        } catch (e) {
          debugPrint('SupabaseService: Ошибка при преобразовании записи: $e, данные: $row');
          continue;
        }
      }

      debugPrint('SupabaseService: Успешно преобразовано ${places.length} мест');
      return places;
    } catch (e, stackTrace) {
      debugPrint('SupabaseService: Ошибка при загрузке мест для города $city: $e');
      debugPrint('SupabaseService: StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<TouristPlace>> loadAllPlaces() async {
    if (!isInitialized) {
      debugPrint('SupabaseService: Supabase не инициализирован');
      return [];
    }

    try {
      debugPrint('SupabaseService: Загрузка всех мест');
      final response = await client
          .from('places')
          .select()
          .order('city')
          .order('title');

      debugPrint('SupabaseService: Получено ${response.length} записей из базы данных');

      final List<TouristPlace> places = [];
      for (var row in response) {
        try {
          places.add(TouristPlace(
            title: row['title'] ?? '',
            subtitle: row['subtitle'] ?? '',
            imagePath: row['image_path'] ?? '',
            address: row['address'] ?? '',
            description: row['description'] ?? '',
            latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
            city: row['city'] ?? '',
            category: row['category'] ?? '',
            isFavorite: false,
          ));
        } catch (e) {
          debugPrint('SupabaseService: Ошибка при преобразовании записи: $e, данные: $row');
          continue;
        }
      }

      debugPrint('SupabaseService: Успешно преобразовано ${places.length} мест');
      return places;
    } catch (e, stackTrace) {
      debugPrint('SupabaseService: Ошибка при загрузке всех мест: $e');
      debugPrint('SupabaseService: StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<String>> loadAvailableCities() async {
    if (!isInitialized) {
      return [];
    }

    try {
      final response = await client
          .from('places')
          .select('city')
          .order('city');

      final cities = <String>{};
      for (var row in response) {
        if (row['city'] != null) {
          cities.add(row['city'] as String);
        }
      }

      return cities.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}

