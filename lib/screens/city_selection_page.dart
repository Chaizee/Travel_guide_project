import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  String _query = '';

  List<String> _baseCities(BuildContext context) {
    // Extended list of cities for scrolling test
    const cities = [
      'Омск', 'Новосибирск', 'Москва'
      // , 'Санкт-Петербург', 'Екатеринбург', 
      // 'Казань', 'Нижний Новгород', 'Челябинск', 'Самара', 
      // 'Ростов-на-Дону', 'Уфа', 'Красноярск', 'Воронеж', 'Пермь',
      // 'Волгоград', 'Краснодар', 'Саратов', 'Тюмень', 'Тольятти'
    ];
    final sorted = List<String>.from(cities)..sort((a, b) => a.compareTo(b));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<FavoritesModel>();
    final cities = _baseCities(context)
        .where((c) => _query.trim().isEmpty || c.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор города'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск города',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: cities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final city = cities[index];
                final selected = model.selectedCity == city;
                return ListTile(
                  title: Text(city, style: theme.textTheme.bodyLarge),
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () async {
                    final alreadyCached = await model.hasCachedDataForCity(city);
                    if (!alreadyCached) {
                      await model.deferAutoDownloadForCity(city);
                    }

                    model.setSelectedCity(city);

                    if (alreadyCached) {
                      final hasInternet = await model.checkInternetConnectionNow();
                      if (!hasInternet) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Нет подключения к сети. Проверка обновлений недоступна.'),
                          ),
                        );
                        Navigator.of(context).pop<String>(city);
                        return;
                      }

                      final newPlaces = await model.fetchNewRemotePlacesForCity(city);
                      if (newPlaces.isNotEmpty) {
                        final shouldUpdate = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Найдены новые места'),
                                  content: Text(
                                    'В городе \"$city\" обнаружено ${newPlaces.length} новых мест. Обновить данные?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: const Text('Позже'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      child: const Text('Обновить'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;

                        if (shouldUpdate) {
                          await model.refreshPlacesForSelectedCity(userInitiated: true);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Данные города обновлены'),
                            ),
                          );
                        } else {
                          await model.deferAutoDownloadForCity(city);
                        }
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Новых мест для этого города нет'),
                          ),
                        );
                      }

                      if (!mounted) return;
                      Navigator.of(context).pop<String>(city);
                      return;
                    }

                    final hasInternet = await model.checkInternetConnectionNow();
                    if (hasInternet) {
                      final shouldDownload = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Загрузить данные?'),
                                content: Text(
                                  'Загрузить места города \"$city\" для офлайн-доступа?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Позже'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('Загрузить'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;

                      if (shouldDownload) {
                        await model.refreshPlacesForSelectedCity(userInitiated: true);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Данные города загружены в память устройства'),
                          ),
                        );
                      } else {
                        await model.loadPlacesWithoutCachingForSelectedCity();
                      }
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Нет подключения к сети. Загрузка недоступна.'),
                        ),
                      );
                    }

                    if (!mounted) return;
                    Navigator.of(context).pop<String>(city);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


