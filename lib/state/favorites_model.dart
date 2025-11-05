import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tourist_places.dart';

class FavoritesModel extends ChangeNotifier {
  FavoritesModel()
      : _places = List<TouristPlace>.from(places) {
    _loadPrefs();
  }

  final List<TouristPlace> _places;
  String _homeQuery = '';
  String _favoritesQuery = '';
  String _selectedCity = 'Все города';
  final Set<String> _selectedCategories = <String>{};

  List<TouristPlace> get allPlaces => _places;
  
  String get selectedCity => _selectedCity;
  
  List<String> get availableCities {
    final cities = _places.map((place) => place.city).toSet().toList();
    cities.insert(0, 'Все города');
    return cities;
  }

  // Fixed set of suggested categories for filtering on Home
  static const List<String> suggestedCategories = <String>[
    'Музей', 'Парк', 'Памятник', 'Театр', 'Архитектура', 'Зоопарк'
  ];

  List<String> get availableCategories {
    final fromData = _places.map((p) => p.category).toSet().toList();
    // Keep consistent order; include only those present
    return suggestedCategories.where((c) => fromData.contains(c)).toList();
  }

  Set<String> get selectedCategories => _selectedCategories;

  List<int> get favoriteIndexes {
    final result = <int>[];
    for (int i = 0; i < _places.length; i++) {
      if (_places[i].isFavorite) result.add(i);
    }
    return result;
  }

  String get homeQuery => _homeQuery;
  String get favoritesQuery => _favoritesQuery;

  void setHomeQuery(String value) {
    _homeQuery = value;
    notifyListeners();
  }

  void setFavoritesQuery(String value) {
    _favoritesQuery = value;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void clearCategories() {
    _selectedCategories.clear();
    notifyListeners();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
    _saveCity();
  }

  List<TouristPlace> get filteredAllPlaces {
    var filteredPlaces = _places;
    
    // Фильтр по городу
    if (_selectedCity != 'Все города') {
      filteredPlaces = filteredPlaces.where((p) => p.city == _selectedCity).toList();
    }

    // Фильтр по категориям
    if (_selectedCategories.isNotEmpty) {
      filteredPlaces = filteredPlaces.where((p) => _selectedCategories.contains(p.category)).toList();
    }
    
    // Фильтр по поисковому запросу
    final q = _homeQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      filteredPlaces = filteredPlaces.where((p) {
        return p.title.toLowerCase().contains(q) || 
               p.subtitle.toLowerCase().contains(q) ||
               p.city.toLowerCase().contains(q) ||
               p.category.toLowerCase().contains(q);
      }).toList();
    }
    
    return filteredPlaces;
  }

  List<int> get filteredFavoriteIndexes {
    final q = _favoritesQuery.trim().toLowerCase();
    List<int> favs = favoriteIndexes;
    
    // Фильтр по выбранному городу
    if (_selectedCity != 'Все города') {
      favs = favs.where((idx) => _places[idx].city == _selectedCity).toList();
    }
    
    // Фильтр по запросу
    if (q.isEmpty) return favs;
    return favs.where((idx) {
      final p = _places[idx];
      return p.title.toLowerCase().contains(q) ||
             p.subtitle.toLowerCase().contains(q) ||
             p.city.toLowerCase().contains(q);
    }).toList();
  }

  void toggleFavorite(int index) {
    if (index < 0 || index >= _places.length) return;
    _places[index] = _places[index].copyWith(
      isFavorite: !_places[index].isFavorite,
    );
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCity = prefs.getString('selected_city') ?? 'Все города';
    
    // Load favorites
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    for (int i = 0; i < _places.length; i++) {
      if (favoritesJson.contains(i.toString())) {
        _places[i] = _places[i].copyWith(isFavorite: true);
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', _selectedCity);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = <String>[];
    for (int i = 0; i < _places.length; i++) {
      if (_places[i].isFavorite) {
        favorites.add(i.toString());
      }
    }
    await prefs.setStringList('favorites', favorites);
  }
}


