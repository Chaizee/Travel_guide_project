import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../widgets/place_card.dart';
import '../widgets/app_header.dart';

class TouristHomePage extends StatefulWidget {
  const TouristHomePage({super.key});

  @override
  State<TouristHomePage> createState() => _TouristHomePageState();
}

class _TouristHomePageState extends State<TouristHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _lastFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Consumer<FavoritesModel>(
              builder: (_, model, __) => Column(
                children: [
                  AppHeader(
                    title: 'Туристические места',
                    searchHint: 'Поиск',
                    onSearchChanged: (value) => model.setHomeQuery(value),
                    searchController: _searchController,
                    onFilterPressed: () async {
                      // Dismiss keyboard before opening the sheet
                      FocusScope.of(context).unfocus();
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        builder: (ctx) {
                          final categories = model.availableCategories;
                          return SafeArea(
                            child: ListView.separated(
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, index) {
                                final cat = categories[index];
                                return ListTile(
                                  leading: const Icon(Icons.label_outline),
                                  title: Text(cat),
                                  onTap: () => Navigator.of(ctx).pop(cat),
                                );
                              },
                            ),
                          );
                        },
                      );
                      if (selected != null && selected.isNotEmpty) {
                        // If a filter was previously selected, replace it instead of appending
                        final token = selected.trim();
                        _lastFilter = token;
                        _searchController.text = token;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: token.length),
                        );
                        model.setHomeQuery(token);
                        // Hide keyboard after applying filter
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FavoritesModel>(
                builder: (_, model, __) {
                  final data = model.filteredAllPlaces;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return PlaceCard(
                        place: data[index],
                        onFavoriteToggle: () {
                          final originalIndex = model.allPlaces.indexOf(data[index]);
                          model.toggleFavorite(originalIndex);
                        },
                      );
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