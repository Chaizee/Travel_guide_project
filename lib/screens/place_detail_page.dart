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
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.place.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final imageHeight = mediaQuery.size.height * 0.55;
    const overlap = 80.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: theme.scaffoldBackgroundColor),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildImage(context, imageHeight),
          ),
          Positioned(
            top: imageHeight - overlap,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, overlap - 60, 24, mediaQuery.padding.bottom + 32),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(context),
                    const SizedBox(height: 24),
                    _buildMapSection(context),
                  ],
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImage(BuildContext context, double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          _buildSingleImage(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    iconSize: 32,
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      
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
        ],
      ),
    );
  }

  Widget _buildSingleImage() {
    final path = widget.place.imagePath;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    final image = isNetwork
        ? Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

    return Image(
      image: image.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(child: Text('Изображение недоступно')),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.place.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        Icon(Icons.location_on, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(widget.place.address, 
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          overflow: TextOverflow.ellipsis, maxLines: 1,
        )),
      ]),
      const SizedBox(height: 16),
      Text(widget.place.description, style: theme.textTheme.bodyLarge),
    ],
  );
}

 Widget _buildMapSection(BuildContext context) {
  final theme = Theme.of(context);
  final lat = widget.place.latitude;
  final lng = widget.place.longitude;
  
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.outline),
    ),
    child: Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              'https://static-maps.yandex.ru/1.x/?'
              'll=$lng,$lat&'
              'z=14&'
              'l=map&'
              'size=600,200&'
              'pt=$lng,$lat,pm2gnl1', 
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.orange[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 50, color: Colors.orange),
                      Text('Ошибка карты: $lat,$lng', style: TextStyle(color: Colors.orange[800])),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        _buildMapButton(context, theme),
      ],
    ),
  );
}

  Widget _buildMapButton(BuildContext context, ThemeData theme) {
    return Container(
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
    );
  }

  Future<void> _openMaps(double latitude, double longitude, String title) async {

    final url = 'https://yandex.ru/maps/?rtext=~$latitude,$longitude&rtt=auto';
    
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
