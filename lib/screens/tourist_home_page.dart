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
                    onSearchChanged: model.setHomeQuery,
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