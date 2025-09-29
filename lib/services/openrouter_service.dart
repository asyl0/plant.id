import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterService {
  static const String baseUrl = 'https://openrouter.ai/api/v1';
  
  String get apiKey => dotenv.env['OPEN_ROUTER_API_KEY'] ?? '';

  Future<Map<String, String>> getPlantInfo(String scientificName) async {
    try {
      final prompt = '''Сіз ботаника маманысыз. $scientificName өсімдігі туралы толық ақпарат беріңіз.

Келесі форматта жауап беріңіз:

ҚАЗАҚША АТЫ: [өсімдіктің қазақша атын жаз]
СИПАТТАМАСЫ: [өсімдіктің сипаттамасын 3-5 сөйлемде жазыңыз - пішіні, жапырақтары, гүлдері, мөлшері туралы]
ПАЙДАСЫ: [өсімдіктің негізгі пайдасын тізіп жазыңыз - емдік қасиеттері, тағам ретінде пайдаланылуы, басқа пайдалары]
ЗИЯНЫ: [өсімдіктің зиянын немесе сақтық шараларын жазыңыз - улылығы, аллергия, басқа қауіптері. Егер зияны жоқ болса "Зияны жоқ" деп жазыңыз]

Әр бөлімді жаңа жолдан бастап, нақты, ғылыми дәл және түсінікті жазыңыз. Машиналық аударма емес, табиғи қазақ тілінде жазыңыз.''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'green_plant_22',
        },
        body: jsonEncode({
          'model': 'openai/gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        return _parseResponse(content);
      } else {
        debugPrint('OpenRouter error: ${response.statusCode} - ${response.body}');
        return _getDefaultInfo(scientificName);
      }
    } catch (e) {
      debugPrint('Error in OpenRouterService: $e');
      return _getDefaultInfo(scientificName);
    }
  }

  Map<String, String> _parseResponse(String content) {
    final result = <String, String>{};
    
    try {
      // Разделяем на строки и очищаем
      final lines = content.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
      
      String currentKey = '';
      String currentValue = '';

      for (var line in lines) {
        // Ищем ключевые слова в начале строки
        if (line.toUpperCase().startsWith('ҚАЗАҚША АТЫ:')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'kazakhName';
          currentValue = line.substring('ҚАЗАҚША АТЫ:'.length).trim();
        } else if (line.toUpperCase().startsWith('СИПАТТАМАСЫ:')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'description';
          currentValue = line.substring('СИПАТТАМАСЫ:'.length).trim();
        } else if (line.toUpperCase().startsWith('ПАЙДАСЫ:')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'benefits';
          currentValue = line.substring('ПАЙДАСЫ:'.length).trim();
        } else if (line.toUpperCase().startsWith('ЗИЯНЫ:')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'harms';
          currentValue = line.substring('ЗИЯНЫ:'.length).trim();
        } else if (currentKey.isNotEmpty) {
          // Продолжаем накапливать значение для текущего ключа
          currentValue += ' $line';
        }
      }

      // Сохраняем последний ключ
      if (currentKey.isNotEmpty) {
        result[currentKey] = currentValue.trim();
      }

      // Очищаем значения от лишних символов
      result.forEach((key, value) {
        result[key] = value
            .replaceFirst(RegExp(r'^\d+\.\s*'), '') // Убираем номера пунктов
            .replaceFirst(RegExp(r'^[-•]\s*'), '') // Убираем маркеры списка
            .trim();
      });

      // Проверяем, что все необходимые поля заполнены
      if (result['kazakhName']?.isEmpty ?? true) {
        result['kazakhName'] = 'Ақпарат жоқ';
      }
      if (result['description']?.isEmpty ?? true) {
        result['description'] = 'Ақпарат жоқ';
      }
      if (result['benefits']?.isEmpty ?? true) {
        result['benefits'] = 'Ақпарат жоқ';
      }
      if (result['harms']?.isEmpty ?? true) {
        result['harms'] = 'Зияны жоқ';
      }

    } catch (e) {
      debugPrint('Error parsing response: $e');
    }

    return result;
  }

  Map<String, String> _getDefaultInfo(String scientificName) {
    return {
      'kazakhName': scientificName,
      'description': 'Ақпарат жоқ',
      'benefits': 'Ақпарат жоқ',
      'harms': 'Зияны жоқ',
    };
  }
}
