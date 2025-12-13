import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/profile_model.dart';
import '../state/favorites_model.dart';
import '../widgets/app_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer2<ProfileModel, FavoritesModel>(
          builder: (_, profile, favs, __) {
            return Column(
              children: [
                const AppHeader(
                  title: 'Личный кабинет',
                  searchHint: '',
                  showSearch: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(profile.bio, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditProfileDialog(context, profile),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Настройки', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Уведомления'),
                          value: profile.notificationsEnabled,
                          onChanged: profile.setNotificationsEnabled,
                        ),
                        
                        const SizedBox(height: 24),
                        const Text('Действия', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _confirmClearFavorites(context, favs),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Очистить избранное'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileModel profile) {
    final nameController = TextEditingController(text: profile.name);
    final bioController = TextEditingController(text: profile.bio);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Редактировать профиль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'О себе'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                profile.setName(nameController.text);
                profile.setBio(bioController.text);
                Navigator.of(ctx).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearFavorites(BuildContext context, FavoritesModel favs) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Очистить избранное?'),
          content: const Text('Это действие удалит все элементы из избранного.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final all = favs.allPlaces;
                for (int i = 0; i < all.length; i++) {
                  if (all[i].isFavorite) favs.toggleFavorite(i);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Очистить'),
            ),
          ],
        );
      },
    );
  }
}
