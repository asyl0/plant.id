class PlantIdentification {
  final String scientificName;
  final List<String> commonNames;
  final double probability;
  final List<String> images;

  PlantIdentification({
    required this.scientificName,
    required this.commonNames,
    required this.probability,
    required this.images,
  });

  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>?;
    
    return PlantIdentification(
      scientificName: species?['scientificName'] as String? ?? 
                     species?['scientific_name'] as String? ?? 
                     'Белгісіз',
      commonNames: (species?['commonNames'] as List<dynamic>? ?? 
                   species?['common_names'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => (e['url'] ?? e.toString()) as String)
          .toList(),
    );
  }
}
