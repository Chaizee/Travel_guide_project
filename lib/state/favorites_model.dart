import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tourist_places.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

class FavoritesModel extends ChangeNotifier {
  FavoritesModel() : _places = <TouristPlace>[] {
    _init();
  }

  Future<void> _init() async {
    await _loadPrefs();
    _initializeConnectivity();
  }

  List<TouristPlace> _places;
  String _homeQuery = '';
  String _favoritesQuery = '';
  String _selectedCity = 'Все города';
  final Set<String> _selectedHomeCategories = <String>{};
  final Set<String> _selectedFavoritesCategories = <String>{};

  bool _hasInternetConnection = true;
  bool _isLoading = false;
  static const String _deferredCitiesPrefsKey = 'deferred_auto_download_cities';
  final Set<String> _deferredAutoDownloadCities = <String>{};
  
  final SupabaseService _supabaseService = SupabaseService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<TouristPlace> get allPlaces => _places;
  
  String get selectedCity => _selectedCity;
  
  bool get hasInternetConnection => _hasInternetConnection;
  bool get isLoading => _isLoading;
  
  Future<bool> hasCachedDataForSelectedCity() async => false;

  Future<bool> hasCachedDataForCity(String city) async => false;

  Future<List<TouristPlace>> fetchNewRemotePlacesForCity(String city) async {
    if (city == 'Все города') return [];

    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return [];

    try {
      final remotePlaces = await _supabaseService.loadPlacesForCity(city);
      if (remotePlaces.isEmpty) return [];

      final cachedPlaces = await _localStorageService.loadPlacesForCity(city);
      final cachedTitles = cachedPlaces.map((p) => p.title).toSet();

      return remotePlaces.where((place) => !cachedTitles.contains(place.title)).toList();
    } catch (_) {
      return [];
    }
  }
  
  List<String> get availableCities {
    final cities = _places.map((place) => place.city).toSet().toList();
    cities.insert(0, 'Все города');
    return cities;
  }

  static const List<String> suggestedCategories = <String>[
    'Музей', 'Парк', 'Памятник', 'Театр', 'Архитектура', 'Зоопарк'
  ];

  List<String> get availableCategories {
    final fromData = _places.map((p) => p.category).toSet().toList();
    return suggestedCategories.where((c) => fromData.contains(c)).toList();
  }

  Set<String> get selectedHomeCategories => _selectedHomeCategories;
  Set<String> get selectedFavoritesCategories => _selectedFavoritesCategories;

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

  void toggleHomeCategory(String category) {
    if (_selectedHomeCategories.contains(category)) {
      _selectedHomeCategories.remove(category);
    } else {
      _selectedHomeCategories.add(category);
    }
    notifyListeners();
  }

  void clearHomeCategories() {
    _selectedHomeCategories.clear();
    notifyListeners();
  }

  void toggleFavoritesCategory(String category) {
    if (_selectedFavoritesCategories.contains(category)) {
      _selectedFavoritesCategories.remove(category);
    } else {
      _selectedFavoritesCategories.add(category);
    }
    notifyListeners();
  }

  void clearFavoritesCategories() {
    _selectedFavoritesCategories.clear();
    notifyListeners();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
    _saveCity();
    _loadCityDataIfNeeded();
  }
  
  Future<void> _loadCityDataIfNeeded() async {
    if (!_isAutoDownloadDeferredFor(_selectedCity)) {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (hasInternet) {
        _loadPlacesForCity(_selectedCity, persistToCache: false);
      }
    }
  }
  
  void _initializeConnectivity() {
    _connectivityService.listenToConnectionChanges((hasConnection) async {
      _hasInternetConnection = hasConnection;
      notifyListeners();
      
      if (hasConnection && _selectedCity != 'Все города') {
        await _loadPlacesForCity(_selectedCity, persistToCache: false, ignoreDeferred: true);
      }
    });
    
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    _hasInternetConnection = await _connectivityService.hasInternetConnection();
    notifyListeners();
  }
  
  Future<void> _loadPlacesForCity(
    String city, {
    bool persistToCache = false,
    bool ignoreDeferred = false,
  }) async {
    if (!ignoreDeferred && city != 'Все города' && _isAutoDownloadDeferredFor(city)) {
      debugPrint('FavoritesModel: Загрузка для города $city пропущена (отложена пользователем)');
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      List<TouristPlace> loadedPlaces = [];
      
      final hasInternet = await _connectivityService.hasInternetConnection();
      _hasInternetConnection = hasInternet;
      
      debugPrint('FavoritesModel: Загрузка мест для города: $city, интернет: $hasInternet');
      
      if (hasInternet) {
        try {
          if (city == 'Все города') {
            loadedPlaces = await _supabaseService.loadAllPlaces();
            debugPrint('FavoritesModel: Загружено ${loadedPlaces.length} мест для всех городов');
          } else {
            loadedPlaces = await _supabaseService.loadPlacesForCity(city);
            debugPrint('FavoritesModel: Загружено ${loadedPlaces.length} мест для города $city');
          }
        } catch (e, stackTrace) {
          debugPrint('FavoritesModel: Ошибка при загрузке из Supabase: $e');
          debugPrint('FavoritesModel: StackTrace: $stackTrace');
          
          loadedPlaces = [];
        }
      } else {
        debugPrint('FavoritesModel: Нет интернета, данных нет без кеша');
      }
      
      if (loadedPlaces.isNotEmpty) {
        await _replacePlacesForCity(city, loadedPlaces);
        debugPrint('FavoritesModel: Всего мест в списке: ${_places.length}');
        await _saveFavorites();
      } else {
        debugPrint('FavoritesModel: Не удалось загрузить места (список пуст)');
      }
    } catch (e, stackTrace) {
      debugPrint('FavoritesModel: Критическая ошибка при загрузке мест: $e');
      debugPrint('FavoritesModel: StackTrace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshPlacesForSelectedCity({bool userInitiated = false}) async {
    if (userInitiated) {
      await allowAutoDownloadForCity(_selectedCity);
    }
    await _loadPlacesForCity(
      _selectedCity,
      ignoreDeferred: userInitiated,
    );
  }

  Future<void> _replacePlacesForCity(String city, List<TouristPlace> loadedPlaces) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    final favoriteTitles = favoritesJson.toSet();

    if (city == 'Все города') {
      _places
        ..clear()
        ..addAll(loadedPlaces.map(
          (place) => place.copyWith(isFavorite: favoriteTitles.contains(place.title)),
        ));
    } else {
      _places.removeWhere((place) => place.city == city);
      for (var place in loadedPlaces) {
        final wasFavorite = favoriteTitles.contains(place.title);
        _places.add(place.copyWith(isFavorite: wasFavorite));
      }
    }
  }

  Future<bool> checkInternetConnectionNow() async {
    final hasConnection = await _connectivityService.hasInternetConnection();
    _hasInternetConnection = hasConnection;
    notifyListeners();
    return hasConnection;
  }

  List<TouristPlace> get filteredAllPlaces {
    var filteredPlaces = _places;
    
    if (_selectedCity != 'Все города') {
      filteredPlaces = filteredPlaces.where((p) => p.city == _selectedCity).toList();
    }

    if (_selectedHomeCategories.isNotEmpty) {
      filteredPlaces = filteredPlaces.where((p) => _selectedHomeCategories.contains(p.category)).toList();
    }
    
    final q = _homeQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      filteredPlaces = filteredPlaces.where((p) {
        return p.title.toLowerCase().contains(q) || 
               p.subtitle.toLowerCase().contains(q) ||
               p.city.toLowerCase().contains(q);
      }).toList();
    }
    
    return filteredPlaces;
  }

  List<int> get filteredFavoriteIndexes {
    final q = _favoritesQuery.trim().toLowerCase();
    List<int> favs = favoriteIndexes;
    
    if (_selectedCity != 'Все города') {
      favs = favs.where((idx) => _places[idx].city == _selectedCity).toList();
    }
    
    if (_selectedFavoritesCategories.isNotEmpty) {
      favs = favs.where((idx) => _selectedFavoritesCategories.contains(_places[idx].category)).toList();
    }
    
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
    
    final deferredCities = prefs.getStringList(_deferredCitiesPrefsKey) ?? [];
    _deferredAutoDownloadCities
      ..clear()
      ..addAll(deferredCities);
    
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    final favoriteTitles = favoritesJson.toSet();
    
    for (int i = 0; i < _places.length; i++) {
      if (favoriteTitles.contains(_places[i].title)) {
        _places[i] = _places[i].copyWith(isFavorite: true);
      }
    }
    
    notifyListeners();
    
    _loadPlacesForCity(_selectedCity, persistToCache: false, ignoreDeferred: true);
  }

  Future<void> _saveCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', _selectedCity);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = <String>[];
    for (var place in _places) {
      if (place.isFavorite) {
        favorites.add(place.title);
      }
    }
    await prefs.setStringList('favorites', favorites);
  }
  
  Future<void> deferAutoDownloadForCity(String city) async {
    if (city == 'Все города') return;
    final added = _deferredAutoDownloadCities.add(city);
    if (added) {
      await _saveDeferredCities();
    }
  }

  Future<void> allowAutoDownloadForCity(String city) async {
    bool changed = false;
    if (city == 'Все города') {
      if (_deferredAutoDownloadCities.isNotEmpty) {
        _deferredAutoDownloadCities.clear();
        changed = true;
      }
    } else {
      changed = _deferredAutoDownloadCities.remove(city);
    }
    if (changed) {
      await _saveDeferredCities();
    }
  }

  bool _isAutoDownloadDeferredFor(String city) {
    if (city == 'Все города') return false;
    return _deferredAutoDownloadCities.contains(city);
  }

  Future<void> _saveDeferredCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _deferredCitiesPrefsKey,
      _deferredAutoDownloadCities.toList(),
    );
  }

  Future<void> loadPlacesWithoutCachingForSelectedCity() async {
    await _loadPlacesForCity(
      _selectedCity,
      persistToCache: false,
      ignoreDeferred: true,
    );
  }
  
  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
