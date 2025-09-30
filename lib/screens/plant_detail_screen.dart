import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../database/database_helper.dart';

class PlantDetailScreen extends StatefulWidget {
  final PlantModel plant;

  const PlantDetailScreen({
    super.key,
    required this.plant,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late PlantModel _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  Future<void> _deletePlant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Жою'),
        content: const Text('Бұл өсімдікті жойғыңыз келеді ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Жоқ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Иә'),
          ),
        ],
      ),
    );

    if (confirmed == true && _plant.id != null) {
      await DatabaseHelper.instance.delete(_plant.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Өсімдік жойылды'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar с фото
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.green[700],
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: _deletePlant,
                icon: const Icon(Icons.delete_outline),
                color: Colors.white,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(_plant.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Контент
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _plant.kazakhName ?? _plant.commonName, // Русское название
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _plant.scientificName, // Научное название
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.verified,
                            '${(_plant.probability * 100).toStringAsFixed(0)}% дәлдік',
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Описание
                if (_plant.description != null && _plant.description!.isNotEmpty)
                  _buildSection(
                    icon: Icons.description,
                    title: 'Сипаттама',
                    content: _plant.description!,
                    color: Colors.blue,
                  ),
                
                // Польза
                if (_plant.benefits != null && _plant.benefits!.isNotEmpty)
                  _buildSection(
                    icon: Icons.favorite,
                    title: 'Пайдасы',
                    content: _plant.benefits!,
                    color: Colors.green,
                  ),
                
                // Вред
                if (_plant.harms != null && _plant.harms!.isNotEmpty)
                  _buildSection(
                    icon: Icons.warning,
                    title: 'Зияны',
                    content: _plant.harms!,
                    color: Colors.orange,
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
