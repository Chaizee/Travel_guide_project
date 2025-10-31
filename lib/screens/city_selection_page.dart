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
      'Омск', 'Новосибирск', 'Москва', 'Санкт-Петербург', 'Екатеринбург', 
      'Казань', 'Нижний Новгород', 'Челябинск', 'Самара', 
      'Ростов-на-Дону', 'Уфа', 'Красноярск', 'Воронеж', 'Пермь',
      'Волгоград', 'Краснодар', 'Саратов', 'Тюмень', 'Тольятти'
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
                  onTap: () {
                    model.setSelectedCity(city);
                    Navigator.of(context).pop();
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


