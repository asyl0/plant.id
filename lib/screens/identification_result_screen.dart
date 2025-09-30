import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/plant_identification.dart';
import '../models/plant_model.dart';
import '../services/plant_id_service.dart';
import '../services/openrouter_service.dart';
import '../database/database_helper.dart';
import 'plant_detail_screen.dart';

class IdentificationResultScreen extends StatefulWidget {
  final String imagePath;

  const IdentificationResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<IdentificationResultScreen> createState() =>
      _IdentificationResultScreenState();
}

class _IdentificationResultScreenState
    extends State<IdentificationResultScreen> {
  final PlantIdService _plantIdService = PlantIdService();
  final OpenRouterService _openRouterService = OpenRouterService();
  bool _isLoading = true;
  List<PlantIdentification> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _identifyPlant();
  }

  Future<void> _identifyPlant() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await _plantIdService.identifyPlant(widget.imagePath);
      
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCatalog(PlantIdentification identification) async {
    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Получаем информацию от OpenRouter
      final plantInfo = await _openRouterService.getPlantInfo(
        identification.scientificName,
        russianName: identification.russianName,
      );

      // Создаем модель растения
      final plant = PlantModel(
        scientificName: identification.scientificName,
        commonName: identification.russianName, // Используем русское название
        imagePath: widget.imagePath,
        probability: identification.probability,
        kazakhName: identification.russianName, // Русское название как kazakhName
        description: plantInfo['description'],
        benefits: plantInfo['benefits'],
        harms: plantInfo['harms'],
      );

      // Сохраняем в базу данных
      final savedPlant = await DatabaseHelper.instance.create(plant);

      // Закрываем диалог загрузки
      if (mounted) Navigator.pop(context);

      // Показываем сообщение об успехе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Каталогқа сәтті қосылды!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Переходим на экран деталей
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: savedPlant),
          ),
        );
      }
    } catch (e) {
      // Закрываем диалог загрузки
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Қате: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Танысты нәтижесі',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Показываем выбранное фото
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Результаты
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 20),
                        Text(
                          'Өсімдікті анықтау...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Қате орын алды',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _identifyPlant,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Қайталап көру'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(
                            child: Text(
                              'Өсімдік табылмады',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final plant = _results[index];
                              return _buildPlantCard(plant);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(PlantIdentification plant) {
    final percentage = (plant.probability * 100).toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с вероятностью
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.russianName, // Используем русское название
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          plant.scientificName, // Научное название внизу
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Похожие фото
          if (plant.images.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: plant.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: plant.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Кнопка добавления в каталог
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addToCatalog(plant),
                icon: const Icon(Icons.add),
                label: const Text('Менің каталогыма қосу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
