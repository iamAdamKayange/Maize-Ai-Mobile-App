class DiseaseModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> symptoms;
  final List<String> preventionMeasures;
  final double confidenceScore;
  final String imagePath;
  final DateTime scannedAt;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.symptoms,
    required this.preventionMeasures,
    required this.confidenceScore,
    required this.imagePath,
    required this.scannedAt,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      preventionMeasures:
          List<String>.from(json['preventionMeasures'] ?? []),
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? '',
      scannedAt: DateTime.tryParse(json['scannedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'description': description,
        'symptoms': symptoms,
        'preventionMeasures': preventionMeasures,
        'confidenceScore': confidenceScore,
        'imagePath': imagePath,
        'scannedAt': scannedAt.toIso8601String(),
      };

  // Sample diseases data
  static List<DiseaseModel> get sampleDiseases => [
        DiseaseModel(
          id: '1',
          name: 'Gray Leaf Spot',
          scientificName: 'Setosphaeria turcica',
          description:
              'A fungal disease causing rectangular gray to tan lesions on leaves, running parallel to the leaf veins.',
          symptoms: [
            'Gray to tan rectangular lesions',
            'Lesions parallel to leaf veins',
            'Premature leaf death',
          ],
          preventionMeasures: [
            'Remove the affected Leaves from plant.',
            'Use Fungicide Sprays.',
            'Practice crop rotation.',
            'Plant resistant varieties.',
          ],
          confidenceScore: 0.75,
          imagePath: '',
          scannedAt: DateTime.now(),
        ),
        DiseaseModel(
          id: '2',
          name: 'Northern Leaf Blight',
          scientificName: 'Exserohilum turcicum',
          description:
              'Fungal infection causing cigar-shaped, tan lesions with wavy margins on maize leaves.',
          symptoms: [
            'Long cigar-shaped lesions',
            'Tan to gray-green color',
            'Dark spores on lesion surface',
          ],
          preventionMeasures: [
            'Apply foliar fungicides at tasseling.',
            'Use resistant hybrids.',
            'Improve air circulation.',
            'Remove plant debris after harvest.',
          ],
          confidenceScore: 0.88,
          imagePath: '',
          scannedAt: DateTime.now(),
        ),
        DiseaseModel(
          id: '3',
          name: 'Common Rust',
          scientificName: 'Puccinia sorghi',
          description:
              'A fungal disease producing brick-red to dark brown pustules on both leaf surfaces.',
          symptoms: [
            'Circular to oval pustules',
            'Brick-red powdery spores',
            'Yellow chlorotic areas around pustules',
          ],
          preventionMeasures: [
            'Plant rust-resistant varieties.',
            'Apply fungicides early in infection.',
            'Monitor fields regularly.',
            'Remove heavily infected plants.',
          ],
          confidenceScore: 0.91,
          imagePath: '',
          scannedAt: DateTime.now(),
        ),
      ];
}
