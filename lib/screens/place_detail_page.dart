import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/tourist_places.dart';
import '../state/favorites_model.dart';

class PlaceDetailPage extends StatefulWidget {
  final TouristPlace place;

  const PlaceDetailPage({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.place.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildImage(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: _buildContent(context),
                  ),
                  _buildMapSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImage(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5, // Растягиваем до половины экрана
      width: double.infinity,
      child: Stack(
        children: [
          // Подготовка для PageView с картинками
          PageView.builder(
            itemCount: 3, // Пока 3 картинки для примера
            controller: PageController(
              viewportFraction: 1.0,
              initialPage: 0,
            ),
            physics: const BouncingScrollPhysics(), // Плавная анимация с отскоком
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Image.asset(
                  widget.place.imagePath, // В будущем здесь будет массив картинок
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Text('Изображение недоступно')),
                    );
                  },
                ),
              );
            },
          ),
          // Кнопки навигации поверх изображения
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 32, // Увеличиваем размер кнопки
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // Стрелка без палочки
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      // Попробуем обновить в модели, если место найдено
                      final model = Provider.of<FavoritesModel>(context, listen: false);
                      final originalIndex = model.allPlaces.indexOf(widget.place);
                      if (originalIndex != -1) {
                        model.toggleFavorite(originalIndex);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Индикаторы страниц
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentImageIndex ? 12 : 8,
                  height: index == _currentImageIndex ? 12 : 8,
                  decoration: BoxDecoration(
                    color: index == _currentImageIndex ? Colors.green : Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: index == _currentImageIndex ? null : Border.all(color: Colors.white, width: 1),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ), // Закругленные края только сверху
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.place.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.place.address,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              // Добавляем оценку из 2GIS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.place.description,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }


  Widget _buildMapSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Карта',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    '${widget.place.latitude.toStringAsFixed(4)}, ${widget.place.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              color: theme.colorScheme.surface,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openMaps(widget.place.latitude, widget.place.longitude, widget.place.title),
              icon: const Icon(Icons.directions),
              label: const Text('Построить маршрут'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(double latitude, double longitude, String title) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude($title)';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      //
    }
  }
}
