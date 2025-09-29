import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/plant_identification.dart';

class PlantIdService {
  static const String baseUrl = 'https://plant.id/api/v3';
  
  String get apiKey => dotenv.env['PLANT_ID_API_KEY'] ?? '';

  Future<List<PlantIdentification>> identifyPlant(String imagePath) async {
    try {
      // Читаем файл и конвертируем в base64
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Формируем запрос согласно документации Plant.id API v3
      final response = await http.post(
        Uri.parse('$baseUrl/identification'),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': apiKey,
        },
        body: jsonEncode({
          'images': ['data:image/jpeg;base64,$base64Image'],
          'similar_images': true,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Проверяем результаты
        if (data['result'] != null && 
            data['result']['classification'] != null &&
            data['result']['classification']['suggestions'] != null) {
          
          final suggestions = data['result']['classification']['suggestions'] as List;
          
          return suggestions.map((suggestion) {
            return PlantIdentification(
              scientificName: suggestion['name'] as String? ?? 'Белгісіз',
              commonNames: (suggestion['details']?['common_names'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList(),
              probability: (suggestion['probability'] as num?)?.toDouble() ?? 0.0,
              images: (suggestion['similar_images'] as List<dynamic>? ?? [])
                  .map((img) => (img['url'] ?? img['url_small']) as String? ?? '')
                  .where((url) => url.isNotEmpty)
                  .take(2)
                  .toList(),
            );
          }).toList();
        }
      }
      
      throw Exception('Өсімдікті анықтау мүмкін болмады. Статус: ${response.statusCode}');
    } catch (e) {
      debugPrint('PlantIdService error: $e');
      throw Exception('Қате: $e');
    }
  }

  Future<Map<String, dynamic>> getPlantDetails(String scientificName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kb/plants/name_search').replace(queryParameters: {
          'q': scientificName,
        }),
        headers: {
          'Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return {};
    } catch (e) {
      debugPrint('Error getting plant details: $e');
      return {};
    }
  }
}
