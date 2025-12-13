class TouristPlace {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isFavorite;
  final String address;
  final String description;
  final double latitude;
  final double longitude;
  final String city;
  final String category;

  TouristPlace({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isFavorite = false,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.category,
  });

  TouristPlace copyWith({bool? isFavorite}) {
    return TouristPlace(
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      address: address,
      description: description,
      latitude: latitude,
      longitude: longitude,
      city: city,
      category: category,
    );
  }
}
