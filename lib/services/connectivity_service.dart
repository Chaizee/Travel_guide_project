import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((r) => 
        r == ConnectivityResult.mobile || 
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet
      );
    } catch (e) {
      return false;
    }
  }

  void listenToConnectionChanges(Function(bool hasConnection) onConnectionChanged) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final hasConnection = results.any((r) => 
          r == ConnectivityResult.mobile || 
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet
        );
        onConnectionChanged(hasConnection);
      },
    );
  }

  void cancelSubscription() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void dispose() {
    cancelSubscription();
  }
}

