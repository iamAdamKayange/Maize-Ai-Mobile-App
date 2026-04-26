class PlantModel {
  final String id;
  final String name;
  final String speciesType;
  final String description;
  final String imagePath;
  final DateTime addedAt;

  PlantModel({
    required this.id,
    required this.name,
    required this.speciesType,
    required this.description,
    required this.imagePath,
    required this.addedAt,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      speciesType: json['speciesType'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'speciesType': speciesType,
        'description': description,
        'imagePath': imagePath,
        'addedAt': addedAt.toIso8601String(),
      };

  static List<PlantModel> get samplePlants => [
        PlantModel(
          id: '1',
          name: 'Hybrid Maize',
          speciesType: 'Hybrid',
          description: 'Hybrid maize is developed for high yield and fast growth.',
          imagePath: '',
          addedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        PlantModel(
          id: '2',
          name: 'Local Maize',
          speciesType: 'Indigenous',
          description: 'Local maize varieties are grown using traditional seeds.',
          imagePath: '',
          addedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        PlantModel(
          id: '3',
          name: 'Sweet Maize',
          speciesType: 'Sweet',
          description:
              'Sweet maize has a high sugar content and is mainly grown for eating fresh.',
          imagePath: '',
          addedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PlantModel(
          id: '4',
          name: 'White Maize',
          speciesType: 'Commercial',
          description:
              'White maize is widely used for food products such as flour and porridge.',
          imagePath: '',
          addedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
}
