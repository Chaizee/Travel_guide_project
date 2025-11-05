import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../widgets/place_card.dart';
import '../widgets/app_header.dart';

class TouristHomePage extends StatelessWidget {
  const TouristHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
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
                    searchController: controller,
                    onFilterPressed: () async {
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
                        final base = controller.text.trim();
                        final token = selected.trim();
                        final next = base.isEmpty ? token : '$base $token';
                        controller.text = next;
                        controller.selection = TextSelection.fromPosition(TextPosition(offset: next.length));
                        model.setHomeQuery(next);
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