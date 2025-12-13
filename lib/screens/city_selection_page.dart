import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/favorites_model.dart';
import '../services/supabase_service.dart';

class CitySelectionPage extends StatefulWidget {
  final String? initialSelectedCity;
  const CitySelectionPage({super.key, this.initialSelectedCity});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  String _query = '';
  late final Future<List<String>> _citiesFuture = SupabaseService().loadAvailableCities();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<FavoritesModel>();
    final selectedCity = widget.initialSelectedCity ?? model.selectedCity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор города'),
      ),
      body: FutureBuilder<List<String>>(
        future: _citiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Ошибка: ${snapshot.error ?? "Не удалось загрузить города"}'));
          }

          List<String> cities = snapshot.data!;
          cities.sort((a, b) => a.compareTo(b));

          List<String> filteredCities = _query.trim().isEmpty
              ? cities
              : cities.where((c) => c.toLowerCase().contains(_query.trim().toLowerCase())).toList();

          return Column(
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
                  itemCount: filteredCities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final selected = selectedCity == city;
                    return ListTile(
                      title: Text(city, style: theme.textTheme.bodyLarge),
                      trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        model.setSelectedCity(city);
                        if (mounted) {
                          Navigator.of(context).pop<String>(city);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
