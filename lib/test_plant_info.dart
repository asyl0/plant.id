// Тестовый файл для демонстрации улучшенного функционала OpenRouter
// Этот файл можно удалить после тестирования

import 'package:flutter/foundation.dart';
import 'services/openrouter_service.dart';

class TestPlantInfo {
  static Future<void> testPlantInfo() async {
    final openRouterService = OpenRouterService();
    
    // Тестируем с разными растениями
    final testPlants = [
      'Rosa chinensis', // Китайская роза
      'Aloe vera', // Алоэ вера
      'Mentha piperita', // Мята перечная
      'Unknown plant', // Неизвестное растение
    ];
    
    for (final plant in testPlants) {
      debugPrint('=== Тестирование: $plant ===');
      
      try {
        final info = await openRouterService.getPlantInfo(plant);
        
        debugPrint('Қазақша аты: ${info['kazakhName']}');
        debugPrint('Сипаттамасы: ${info['description']}');
        debugPrint('Пайдасы: ${info['benefits']}');
        debugPrint('Зияны: ${info['harms']}');
        debugPrint('');
        
      } catch (e) {
        debugPrint('Қате: $e');
        debugPrint('');
      }
    }
  }
}

// Пример использования:
// TestPlantInfo.testPlantInfo();
