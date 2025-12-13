import 'package:flutter/material.dart';
import '../data/tourist_places.dart';
import '../screens/place_detail_page.dart';

class PlaceCard extends StatelessWidget {
  final TouristPlace place;
  final VoidCallback onFavoriteToggle;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onFavoriteToggle,
  });

  void _openPlace(BuildContext context) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetailPage(place: place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _openPlace(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildImage(),
                _buildGradientOverlay(),
                _buildTitle(),
                _buildSubtitle(),
                _buildFavoriteIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = place.imagePath;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    final image = isNetwork
        ? Image.network(
            path,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          )
        : Image.asset(
            path,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          );

    return Image(
      image: image.image,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          color: Colors.grey[300],
          child: const Center(child: Text('Изображение недоступно')),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black38],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      left: 16,
      bottom: 32,
      child: Text(
        place.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Positioned(
      left: 16,
      bottom: 14,
      child: Text(
        place.subtitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return Positioned(
      right: 8,
      top: 8,
      child: IconButton(
        icon: Icon(
          place.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 28,
          color: place.isFavorite ? Colors.red : Colors.white,
        ),
        onPressed: onFavoriteToggle,
        splashRadius: 20,
      ),
    );
  }
}
