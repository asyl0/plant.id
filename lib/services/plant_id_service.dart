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
        // Получаем русские названия из common_names
        final commonNames = (suggestion['details']?['common_names'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        
        // Ищем русское название (обычно первое в списке)
        // Если нет русских названий, используем научное название
        final scientificName = suggestion['name'] as String? ?? 'Белгісіз';
        final russianName = commonNames.isNotEmpty ? commonNames.first : _getRussianNameFromScientific(scientificName);
        
        return PlantIdentification(
          scientificName: suggestion['name'] as String? ?? 'Белгісіз',
          commonNames: commonNames,
          russianName: russianName, // Добавляем русское название
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

  // Функция для получения русских названий из научных
  String _getRussianNameFromScientific(String scientificName) {
    // Словарь известных растений
    final plantNames = {
      'Nymphaea x marliacea': 'Кувшинка гибридная',
      'Nymphaea alba': 'Кувшинка белая',
      'Nymphaea': 'Кувшинка',
      'Rosa chinensis': 'Роза китайская',
      'Rosa': 'Роза',
      'Aloe vera': 'Алоэ вера',
      'Mentha piperita': 'Мята перечная',
      'Kroenleinia grusonii': 'Эхинокактус Грузона',
      'Cactus': 'Кактус',
      'Lily': 'Лилия',
      'Tulip': 'Тюльпан',
      'Sunflower': 'Подсолнечник',
      'Rose': 'Роза',
      'Lavender': 'Лаванда',
      'Jasmine': 'Жасмин',
      'Orchid': 'Орхидея',
      'Fern': 'Папоротник',
      'Pine': 'Сосна',
      'Oak': 'Дуб',
      'Maple': 'Клен',
      'Birch': 'Береза',
      'Willow': 'Ива',
      'Poplar': 'Тополь',
      'Linden': 'Липа',
      'Spruce': 'Ель',
      'Fir': 'Пихта',
      'Cedar': 'Кедр',
      'Juniper': 'Можжевельник',
      'Thuja': 'Туя',
      'Cypress': 'Кипарис',
      'Magnolia': 'Магнолия',
      'Cherry': 'Вишня',
      'Apple': 'Яблоня',
      'Pear': 'Груша',
      'Plum': 'Слива',
      'Peach': 'Персик',
      'Apricot': 'Абрикос',
      'Walnut': 'Грецкий орех',
      'Hazel': 'Лещина',
      'Almond': 'Миндаль',
      'Pistachio': 'Фисташка',
      'Pecan': 'Пекан',
      'Acorn': 'Желудь',
      'Pine cone': 'Сосновая шишка',
      'Fir cone': 'Еловая шишка',
      'Cedar cone': 'Кедровая шишка',
      'Juniper berry': 'Можжевеловая ягода',
      'Rose hip': 'Шиповник',
      'Hawthorn': 'Боярышник',
      'Elderberry': 'Бузина',
      'Viburnum': 'Калина',
      'Rowan': 'Рябина',
      'Bird cherry': 'Черемуха',
      'Lilac': 'Сирень',
      'Honeysuckle': 'Жимолость',
      'Wisteria': 'Глициния',
      'Clematis': 'Клематис',
      'Ivy': 'Плющ',
      'Grape': 'Виноград',
      'Hops': 'Хмель',
      'Morning glory': 'Ипомея',
      'Sweet pea': 'Душистый горошек',
      'Nasturtium': 'Настурция',
      'Petunia': 'Петуния',
      'Geranium': 'Герань',
      'Begonia': 'Бегония',
      'Fuchsia': 'Фуксия',
      'Impatiens': 'Бальзамин',
      'Marigold': 'Бархатцы',
      'Zinnia': 'Цинния',
      'Aster': 'Астра',
      'Chrysanthemum': 'Хризантема',
      'Dahlia': 'Георгин',
      'Gladiolus': 'Гладиолус',
      'Iris': 'Ирис',
      'Daffodil': 'Нарцисс',
      'Hyacinth': 'Гиацинт',
      'Crocus': 'Крокус',
      'Snowdrop': 'Подснежник',
      'Lily of the valley': 'Ландыш',
      'Forget-me-not': 'Незабудка',
      'Pansy': 'Анютины глазки',
      'Violet': 'Фиалка',
      'Primrose': 'Примула',
      'Cyclamen': 'Цикламен',
      'Azalea': 'Азалия',
      'Rhododendron': 'Рододендрон',
      'Camellia': 'Камелия',
      'Hibiscus': 'Гибискус',
      'Bougainvillea': 'Бугенвиллия',
      'Oleander': 'Олеандр',
      'Gardenia': 'Гардения',
      'Stephanotis': 'Стефанотис',
      'Plumeria': 'Плюмерия',
      'Frangipani': 'Франжипани',
    };

    // Ищем точное совпадение
    if (plantNames.containsKey(scientificName)) {
      return plantNames[scientificName]!;
    }

    // Ищем по частичному совпадению
    for (final entry in plantNames.entries) {
      if (scientificName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(scientificName.toLowerCase())) {
        return entry.value;
      }
    }

    // Если не найдено, возвращаем научное название
    return scientificName;
  }
}
