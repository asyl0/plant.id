import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterService {
  static const String baseUrl = 'https://openrouter.ai/api/v1';
  
  String get apiKey => dotenv.env['OPEN_ROUTER_API_KEY'] ?? '';

  Future<Map<String, String>> getPlantInfo(String scientificName, {String? russianName}) async {
    try {
      // Используем русское название если есть, иначе научное
      final plantName = russianName ?? scientificName;
      
      final prompt = '''Сіз ботаника маманысыз және қазақ тілінің маманысыз. $plantName өсімдігі туралы толық ақпарат беріңіз.

МАҢЫЗДЫ ТАЛАПТАР:
- Барлық жауапты ТЕК қазақ тілінде ғана жазыңыз!
- Орыс, ағылшын немесе басқа тілдерде жазбаңыз!
- Қазақ тілінің грамматикасын дұрыс қолданыңыз
- Табиғи, түсінікті және әдеби қазақ тілінде жазыңыз
- Машиналық аударма стилінде жазбаңыз
- Қазақ тілінің лексикасын дұрыс қолданыңыз
- Сипаттамада, пайдасында және зиянында өсімдіктің атауын "$plantName" деп атаңыз

КЕЛЕСІ ФОРМАТТА ЖАУАП БЕРІҢІЗ:

СИПАТТАМАСЫ: [$plantName өсімдігінің толық сипаттамасын 5-7 сөйлемде жазыңыз. Өсімдіктің пішіні, жапырақтары, гүлдері, мөлшері, өсу ортасы, түсі, ерекшеліктері, құрылымы туралы толық ақпарат беріңіз. Сипаттаманы "$plantName" деп бастаңыз және қазақ тілінің әдеби стилінде жазыңыз]

ПАЙДАСЫ: [$plantName өсімдігінің пайдасын толық тізіп жазыңыз. Емдік қасиеттері, тағам ретінде пайдаланылуы, көркемдік мақсатта өсірілуі, экологиялық маңызы, адам денсаулығына тиімділігі, басқа пайдалары туралы айтыңыз. Әр пайданы жеке сөйлеммен сипаттаңыз]

ЗИЯНЫ: [$plantName өсімдігінің зиянын немесе сақтық шараларын толық жазыңыз. Улылығы, аллергия, басқа қауіптері, қолдану кезіндегі ескертулер, қауіпсіздік шаралары туралы айтыңыз. Егер зияны жоқ болса "Зияны жоқ" деп жазыңыз. Әр зиянды жеке сөйлеммен сипаттаңыз]

ҚОСЫМША ТАЛАПТАР:
- Әр бөлімді жаңа жолдан бастаңыз
- Нақты, ғылыми дәл және түсінікті жазыңыз
- Машиналық аударма емес, табиғи қазақ тілінде жазыңыз
- Қазақ тілінің грамматикасын дұрыс қолданыңыз
- Лексиканы дұрыс таңдаңыз
- Сөйлем құрылымын дұрыс жасаңыз
- Барлық ақпаратты толық және нақты беріңіз
- Әдеби қазақ тілінде жазыңыз''';

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
        // Ищем ключевые слова в начале строки (учитываем возможные варианты)
        if (line.toUpperCase().startsWith('СИПАТТАМАСЫ:') || 
            line.toUpperCase().startsWith('СИПАТТАМА:') ||
            line.toUpperCase().startsWith('СИПАТТАМАСЫ') ||
            line.toUpperCase().startsWith('СИПАТТАМА')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'description';
          // Убираем различные варианты префикса
          currentValue = line
              .replaceFirst(RegExp(r'^СИПАТТАМАСЫ:?\s*', caseSensitive: false), '')
              .replaceFirst(RegExp(r'^СИПАТТАМА:?\s*', caseSensitive: false), '')
              .trim();
        } else if (line.toUpperCase().startsWith('ПАЙДАСЫ:') || 
                   line.toUpperCase().startsWith('ПАЙДАСЫ') ||
                   line.toUpperCase().startsWith('ПАЙДА:') ||
                   line.toUpperCase().startsWith('ПАЙДА')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'benefits';
          // Убираем различные варианты префикса
          currentValue = line
              .replaceFirst(RegExp(r'^ПАЙДАСЫ:?\s*', caseSensitive: false), '')
              .replaceFirst(RegExp(r'^ПАЙДА:?\s*', caseSensitive: false), '')
              .trim();
        } else if (line.toUpperCase().startsWith('ЗИЯНЫ:') || 
                   line.toUpperCase().startsWith('ЗИЯНЫ') ||
                   line.toUpperCase().startsWith('ЗИЯН:') ||
                   line.toUpperCase().startsWith('ЗИЯН')) {
          if (currentKey.isNotEmpty) {
            result[currentKey] = currentValue.trim();
          }
          currentKey = 'harms';
          // Убираем различные варианты префикса
          currentValue = line
              .replaceFirst(RegExp(r'^ЗИЯНЫ:?\s*', caseSensitive: false), '')
              .replaceFirst(RegExp(r'^ЗИЯН:?\s*', caseSensitive: false), '')
              .trim();
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
            .replaceFirst(RegExp(r'^[-•*]\s*'), '') // Убираем маркеры списка
            .replaceFirst(RegExp(r'^[•·]\s*'), '') // Убираем другие маркеры
            .replaceAll(RegExp(r'\s+'), ' ') // Убираем лишние пробелы
            .trim();
      });

      // Проверяем, что все необходимые поля заполнены
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
      'description': 'Ақпарат жоқ',
      'benefits': 'Ақпарат жоқ',
      'harms': 'Зияны жоқ',
    };
  }
}
