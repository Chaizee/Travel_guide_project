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
  final String category; // e.g., Музей, Парк, Памятник, Театр, Архитектура, Зоопарк

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

// List<TouristPlace> places = [
//   // Омск
//   TouristPlace(
//     title: 'Собор святого пети',
//     subtitle: 'Крупнейший и старейший академический...',
//     imagePath: 'assets/images/dram.jpg',
//     address: 'ул. Ленина, 1, Омск',
//     description: 'Один из старейших театров России, основанный в 1874 году. Архитектурный памятник федерального значения.',
//     latitude: 54.9889,
//     longitude: 73.3686,
//     city: 'Омск',
//     category: 'Архитектура',
//   ),
//   TouristPlace(
//     title: 'Левое яичко ленина',
//     subtitle: 'Современная архитектурная деталь...',
//     imagePath: 'assets/images/shar.jpg',
//     address: 'ул. Ленина, 3, Омск',
//     description: 'Современная скульптурная композиция, созданная в 2010 году. Символ современного искусства города.',
//     latitude: 54.9891,
//     longitude: 73.3688,
//     city: 'Омск',
//     category: 'Памятник',
//   ),
//   TouristPlace(
//     title: 'Портал в ад',
//     subtitle: 'Уникальный вход в преисподниюю...',
//     imagePath: 'assets/images/metro.jpg',
//     address: 'ул. Маркса, 15, Омск',
//     description: 'Станция метро с уникальным дизайном, открытая в 2013 году. Современная архитектура подземки.',
//     latitude: 54.9875,
//     longitude: 73.3650,
//     city: 'Омск',
//     category: 'Архитектура',
//   ),
//   TouristPlace(
//     title: 'Вышка 5G',
//     subtitle: 'Через нее государство собиралось...',
//     imagePath: 'assets/images/kalancha.jpg',
//     address: 'ул. Пушкина, 7, Омск',
//     description: 'Телевизионная башня высотой 180 метров. Символ технического прогресса города.',
//     latitude: 54.9900,
//     longitude: 73.3700,
//     city: 'Омск',
//     category: 'Архитектура',
//   ),
//   TouristPlace(
//     title: 'Дед палкой машет',
//     subtitle: 'Он был главным в деле о...',
//     imagePath: 'assets/images/ded.jpg',
//     address: 'ул. Красный Путь, 25, Омск',
//     description: 'Памятник основателю города, установленный в 2003 году. Исторический символ Омска.',
//     latitude: 54.9850,
//     longitude: 73.3600,
//     city: 'Омск',
//     category: 'Памятник',
//   ),
  
//   // Новосибирск
//   TouristPlace(
//     title: 'Новосибирский театр оперы и балета',
//     subtitle: 'Крупнейший театральный комплекс России...',
//     imagePath: 'assets/images/dram.jpg', // Используем существующее изображение
//     address: 'Красный проспект, 36, Новосибирск',
//     description: 'Один из крупнейших театров России, открытый в 1945 году. Архитектурный символ Новосибирска с уникальным куполом.',
//     latitude: 55.0302,
//     longitude: 82.9204,
//     city: 'Новосибирск',
//     category: 'Театр',
//   ),
//   TouristPlace(
//     title: 'Новосибирский зоопарк',
//     subtitle: 'Один из крупнейших зоопарков России...',
//     imagePath: 'assets/images/shar.jpg', // Используем существующее изображение
//     address: 'ул. Тимирязева, 71/1, Новосибирск',
//     description: 'Один из крупнейших зоопарков России, основанный в 1947 году. Содержит более 11 тысяч животных 770 видов.',
//     latitude: 55.0533,
//     longitude: 82.9097,
//     city: 'Новосибирск',
//     category: 'Зоопарк',
//   ),
//   TouristPlace(
//     title: 'Музей железнодорожной техники',
//     subtitle: 'Уникальная коллекция железнодорожной техники...',
//     imagePath: 'assets/images/metro.jpg', // Используем существующее изображение
//     address: 'ул. Разъездная, 54/1, Новосибирск',
//     description: 'Музей под открытым небом с коллекцией паровозов, тепловозов и вагонов разных эпох. Основан в 2000 году.',
//     latitude: 55.0189,
//     longitude: 82.9336,
//     city: 'Новосибирск',
//     category: 'Музей',
//   ),
//   TouristPlace(
//     title: 'Памятник лабораторной мыши',
//     subtitle: 'Символ научных достижений города...',
//     imagePath: 'assets/images/kalancha.jpg', // Используем существующее изображение
//     address: 'пр. Академика Лаврентьева, 10, Новосибирск',
//     description: 'Памятник лабораторной мыши, вяжущей ДНК. Символизирует вклад новосибирских ученых в развитие генетики.',
//     latitude: 54.8419,
//     longitude: 83.0956,
//     city: 'Новосибирск',
//     category: 'Памятник',
//   ),
//   TouristPlace(
//     title: 'Собор Александра Невского',
//     subtitle: 'Православный храм в центре города...',
//     imagePath: 'assets/images/ded.jpg', // Используем существующее изображение
//     address: 'ул. Советская, 1а, Новосибирск',
//     description: 'Православный храм, построенный в 1899 году. Один из старейших каменных храмов Новосибирска.',
//     latitude: 55.0208,
//     longitude: 82.9247,
//     city: 'Новосибирск',
//     category: 'Архитектура',
//   ),
// ];