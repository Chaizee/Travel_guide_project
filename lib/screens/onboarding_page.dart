import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/profile_model.dart';
import '../state/favorites_model.dart';
import 'main_screen.dart';
import 'city_selection_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late bool _darkMode;
  late String _city;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileModel>();
    final favs = context.read<FavoritesModel>();
    _darkMode = profile.darkModeEnabled;
    _city = favs.selectedCity == 'Все города' ? 'Омск' : favs.selectedCity;
  }

  Future<void> _completeOnboarding() async {
    final profile = context.read<ProfileModel>();
    final favs = context.read<FavoritesModel>();
    profile.setDarkModeEnabled(_darkMode);
    favs.setSelectedCity(_city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80), // Space below theme icon
                  Text('Добро пожаловать!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Выберите город.', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Text('Город', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.of(context).push<String>(
                                MaterialPageRoute(
                                  builder: (_) => const CitySelectionPage(),
                                ),
                              );
                              if (result != null) {
                                setState(() => _city = result);
                              }
                            },
                            icon: const Icon(Icons.location_city),
                            label: Text(_city),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text(
                        'Подтвердить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Theme toggle button in top-left corner
            Positioned(
              top: 16,
              left: 16,
              child: Consumer<ProfileModel>(
                builder: (_, profile, __) {
                  final isDark = _darkMode;
                  return IconButton(
                    icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
                    tooltip: isDark ? 'Светлая тема' : 'Темная тема',
                    onPressed: () {
                      setState(() => _darkMode = !_darkMode);
                      profile.setDarkModeEnabled(_darkMode);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


