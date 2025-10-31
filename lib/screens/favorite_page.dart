import 'package:flutter/material.dart';
//import 'tourist_home_page.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../widgets/place_card.dart';
import '../widgets/app_header.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<FavoritesModel>(
          builder: (_, model, __) {
            final favoriteIndexes = model.filteredFavoriteIndexes;
            return Column(
              children: [
                AppHeader(
                  title: 'Избранное',
                  searchHint: 'Поиск в избранном',
                  onSearchChanged: model.setFavoritesQuery,
                ),
                Expanded(
                  child: favoriteIndexes.isEmpty
                      ? const Center(child: Text('Нет избранных мест'))
                      : ListView.builder(
                          itemCount: favoriteIndexes.length,
                          itemBuilder: (context, filteredIndex) {
                            final originalIndex = favoriteIndexes[filteredIndex];
                            return PlaceCard(
                              place: model.allPlaces[originalIndex],
                              onFavoriteToggle: () => model.toggleFavorite(originalIndex),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
