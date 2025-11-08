import 'package:flutter/material.dart';
//import 'tourist_home_page.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../widgets/place_card.dart';
import '../widgets/app_header.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvoked: (_) {
        // Убираем фокус при нажатии кнопки "назад"
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
        child: Column(
          children: [
            Consumer<FavoritesModel>(
              builder: (_, model, __) => Column(
                children: [
                  AppHeader(
                    title: 'Избранное',
                    searchHint: 'Поиск в избранном',
                    onSearchChanged: model.setFavoritesQuery,
                    onFilterPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    onSearchFocus: () {
                      if (_showFilters) {
                        setState(() {
                          _showFilters = false;
                        });
                      }
                    },
                    selectedFiltersCount: model.selectedFavoritesCategories.length,
                  ),
                  // Expandable filters panel
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showFilters
                        ? Container(
                            color: theme.colorScheme.surface,
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: _buildFiltersTab(context, theme, model),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FavoritesModel>(
                builder: (_, model, __) {
                  final favoriteIndexes = model.filteredFavoriteIndexes;
                  if (favoriteIndexes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Нет избранных мест',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: favoriteIndexes.length,
                    itemBuilder: (context, filteredIndex) {
                      final originalIndex = favoriteIndexes[filteredIndex];
                      return PlaceCard(
                        place: model.allPlaces[originalIndex],
                        onFavoriteToggle: () => model.toggleFavorite(originalIndex),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFiltersTab(BuildContext context, ThemeData theme, FavoritesModel model) {
    if (model.availableCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Категории не доступны'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Выберите категории',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (model.selectedFavoritesCategories.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    model.clearFavoritesCategories();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Очистить все'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: model.availableCategories.map((category) {
              final isSelected = model.selectedFavoritesCategories.contains(category);
              return FilterChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  model.toggleFavoritesCategory(category);
                  setState(() {
                    _showFilters = false;
                  });
                  FocusScope.of(context).unfocus();
                },
                avatar: isSelected
                    ? Icon(Icons.check, size: 20, color: theme.colorScheme.onPrimaryContainer)
                    : Icon(
                        _getCategoryIcon(category),
                        size: 20,
                      ),
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          if (model.selectedFavoritesCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Выбрано категорий: ${model.selectedFavoritesCategories.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Музей':
        return Icons.museum_outlined;
      case 'Парк':
        return Icons.forest_outlined;
      case 'Памятник':
        return Icons.account_tree_outlined;
      case 'Театр':
        return Icons.theater_comedy_outlined;
      case 'Архитектура':
        return Icons.architecture_outlined;
      case 'Зоопарк':
        return Icons.pets_outlined;
      default:
        return Icons.label_outline;
    }
  }
}
