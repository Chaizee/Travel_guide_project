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
  final VoidCallback? onSearchFocus;
  final int? selectedFiltersCount;
  final FocusNode? searchFocusNode;

  const AppHeader({
    super.key,
    required this.title,
    this.showSearch = true,
    this.searchHint = 'Поиск',
    this.onSearchChanged,
    this.onFilterPressed,
    this.onSearchFocus,
    this.selectedFiltersCount,
    this.searchFocusNode,
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
                  FocusScope.of(context).unfocus();
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
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: onFilterPressed != null
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            tooltip: 'Фильтры',
                            icon: const Icon(Icons.filter_alt),
                            onPressed: onFilterPressed,
                          ),
                          if (selectedFiltersCount != null && selectedFiltersCount! > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  selectedFiltersCount! > 9 ? '9+' : selectedFiltersCount!.toString(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onError,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onChanged: onSearchChanged,
              onSubmitted: onSearchChanged,
              onTap: onSearchFocus,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


