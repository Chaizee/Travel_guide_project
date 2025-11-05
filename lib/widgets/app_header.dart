import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_guide/state/favorites_model.dart';
import 'package:travel_guide/screens/city_selection_page.dart';
import '../state/profile_model.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showSearch;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final TextEditingController? searchController;

  const AppHeader({
    super.key,
    required this.title,
    this.showSearch = true,
    this.searchHint = 'Поиск',
    this.onSearchChanged,
    this.onFilterPressed,
    this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Consumer<ProfileModel>(
                builder: (_, profile, __) {
                  final isDark = profile.darkModeEnabled;
                  return IconButton(
                    icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
                    tooltip: isDark ? 'Светлая тема' : 'Темная тема',
                    onPressed: () => profile.setDarkModeEnabled(!isDark),
                  );
                },
              ),
              const Spacer(),
              Consumer<FavoritesModel>(
                builder: (_, favs, __) {
                  final city = favs.selectedCity == 'Все города' ? 'Все города' : favs.selectedCity;
                  return Text(city.toUpperCase(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Выбрать город',
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CitySelectionPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (showSearch)
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Фильтр',
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: onFilterPressed,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: onSearchChanged,
              onSubmitted: onSearchChanged,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


