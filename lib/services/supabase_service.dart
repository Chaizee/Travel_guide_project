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
      return [];
    }

    try {
      final response = await client
          .from('places')
          .select()
          .eq('city', city)
          .order('title');
      
      final List<TouristPlace> places = [];
      for (var row in response) {
        try {
          final imagePath = row['image_url'] ?? row['image_path'] ?? '';
          places.add(TouristPlace(
            title: row['title'] ?? '',
            subtitle: row['subtitle'] ?? '',
            imagePath: imagePath,
            address: row['address'] ?? '',
            description: row['description'] ?? '',
            latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
            city: row['city'] ?? city,
            category: row['category'] ?? '',
            isFavorite: false,
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

  Future<List<TouristPlace>> loadAllPlaces() async {
    if (!isInitialized) {
      return [];
    }

    try {
      final response = await client
          .from('places')
          .select()
          .order('city')
          .order('title');

      final List<TouristPlace> places = [];
      for (var row in response) {
        try {
          final imagePath = row['image_url'] ?? row['image_path'] ?? '';
          places.add(TouristPlace(
            title: row['title'] ?? '',
            subtitle: row['subtitle'] ?? '',
            imagePath: imagePath,
            address: row['address'] ?? '',
            description: row['description'] ?? '',
            latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
            city: row['city'] ?? '',
            category: row['category'] ?? '',
            isFavorite: false,
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

  Future<List<String>> loadAvailableCategories() async {
    if (!isInitialized) {
      return [];
    }

    try {
      final response = await client
          .from('places')
          .select('category')
          .order('category');

      final categories = <String>{};
      for (var row in response) {
        if (row['category'] != null) {
          categories.add(row['category'] as String);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}

