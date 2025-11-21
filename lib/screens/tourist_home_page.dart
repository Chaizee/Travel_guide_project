import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../widgets/place_card.dart';
import '../widgets/app_header.dart';
import '../utils/route_observer.dart';

class TouristHomePage extends StatefulWidget {
  const TouristHomePage({super.key});

  @override
  State<TouristHomePage> createState() => _TouristHomePageState();
}

class _TouristHomePageState extends State<TouristHomePage> with RouteAware {
  bool _showFilters = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _searchFocusNode.unfocus();
  }

  @override
  void didPushNext() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
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
                    title: 'Туристические места',
                    searchHint: 'Поиск',
                    onSearchChanged: (value) => model.setHomeQuery(value),
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
                    selectedFiltersCount: model.selectedHomeCategories.length,
                    searchFocusNode: _searchFocusNode,
                  ),

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
                  return FutureBuilder<bool>(
                    future: model.hasCachedDataForSelectedCity(),
                    builder: (context, snapshot) {
                      final hasCachedData = snapshot.data ?? false;
                      final data = model.filteredAllPlaces;
                      
                      if (!model.hasInternetConnection && !hasCachedData && data.isEmpty) {
                        return _buildNoInternetNoCacheMessage(context, theme, model);
                      }
                      
                      if (model.isLoading && data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Загрузка мест...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ничего не найдено',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Попробуйте изменить фильтры или поисковый запрос',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
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
              if (model.selectedHomeCategories.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    model.clearHomeCategories();
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
              final isSelected = model.selectedHomeCategories.contains(category);
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
                  model.toggleHomeCategory(category);
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
          if (model.selectedHomeCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                      'Выбрано категорий: ${model.selectedHomeCategories.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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

  Widget _buildNoInternetNoCacheMessage(
    BuildContext context,
    ThemeData theme,
    FavoritesModel model,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Нет подключения к интернету',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Для просмотра мест необходимо подключение к интернету. '
              'После первой загрузки данные будут доступны офлайн.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                // Пытаемся обновить данные без сохранения в кэше
                await model.loadPlacesWithoutCachingForSelectedCity();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}