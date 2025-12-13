import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state/favorites_model.dart';
import 'state/profile_model.dart';
import 'utils/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://htimpljsozsbiikmjvrd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0aW1wbGpzb3pzYmlpa21qdnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjgxMDYsImV4cCI6MjA3ODEwNDEwNn0.Qg2ymZSoJlZAuGX6Xu_SJshFcOynG9ySll0RFeRd7sE',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    debugPrint('App will continue with local data');
  }
  
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  final savedCity = prefs.getString('selected_city');
  final shouldShowOnboarding = !completed || savedCity == null || savedCity == 'Все города';
  runApp(TouristApp(showOnboarding: shouldShowOnboarding));
}

class TouristApp extends StatelessWidget {
  final bool showOnboarding;
  const TouristApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
      ],
      child: Consumer<ProfileModel>(
        builder: (_, profile, __) {
          final lightTheme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F6D7A), brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF7F7F7),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFEAEAEA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            fontFamily: 'Raleway',
          );

          final darkTheme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9EC1CF), brightness: Brightness.dark),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            fontFamily: 'Raleway',
          );

          return MaterialApp(
            title: 'Travel Guid',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: profile.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            themeAnimationDuration: Duration.zero,
            themeAnimationCurve: Curves.linear,
            home: LoadingPage(showOnboarding: showOnboarding),
            navigatorObservers: [appRouteObserver],
          );
        },
      ),
    );
  }
}
