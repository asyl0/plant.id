import 'dart:convert';

class PlantModel {
  final int? id;
  final String scientificName;
  final String commonName;
  final String imagePath;
  final double probability;
  final String? kazakhName;
  final String? description;
  final String? benefits;
  final String? harms;
  final DateTime dateAdded;

  PlantModel({
    this.id,
    required this.scientificName,
    required this.commonName,
    required this.imagePath,
    required this.probability,
    this.kazakhName,
    this.description,
    this.benefits,
    this.harms,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scientific_name': scientificName,
      'common_name': commonName,
      'image_path': imagePath,
      'probability': probability,
      'kazakh_name': kazakhName,
      'description': description,
      'benefits': benefits,
      'harms': harms,
      'date_added': dateAdded.toIso8601String(),
    };
  }

  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      id: map['id'] as int?,
      scientificName: map['scientific_name'] as String,
      commonName: map['common_name'] as String,
      imagePath: map['image_path'] as String,
      probability: map['probability'] as double,
      kazakhName: map['kazakh_name'] as String?,
      description: map['description'] as String?,
      benefits: map['benefits'] as String?,
      harms: map['harms'] as String?,
      dateAdded: DateTime.parse(map['date_added'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlantModel.fromJson(String source) =>
      PlantModel.fromMap(json.decode(source) as Map<String, dynamic>);

  PlantModel copyWith({
    int? id,
    String? scientificName,
    String? commonName,
    String? imagePath,
    double? probability,
    String? kazakhName,
    String? description,
    String? benefits,
    String? harms,
    DateTime? dateAdded,
  }) {
    return PlantModel(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      commonName: commonName ?? this.commonName,
      imagePath: imagePath ?? this.imagePath,
      probability: probability ?? this.probability,
      kazakhName: kazakhName ?? this.kazakhName,
      description: description ?? this.description,
      benefits: benefits ?? this.benefits,
      harms: harms ?? this.harms,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
