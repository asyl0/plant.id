import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plants.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
CREATE TABLE plants (
  id $idType,
  scientific_name $textType,
  common_name $textType,
  image_path $textType,
  probability $doubleType,
  kazakh_name $textTypeNullable,
  description $textTypeNullable,
  benefits $textTypeNullable,
  harms $textTypeNullable,
  date_added $textType
)
''');
  }

  Future<PlantModel> create(PlantModel plant) async {
    final db = await instance.database;
    final id = await db.insert('plants', plant.toMap());
    return plant.copyWith(id: id);
  }

  Future<PlantModel?> readPlant(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'plants',
      columns: [
        'id',
        'scientific_name',
        'common_name',
        'image_path',
        'probability',
        'kazakh_name',
        'description',
        'benefits',
        'harms',
        'date_added'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PlantModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<PlantModel>> readAllPlants() async {
    final db = await instance.database;
    const orderBy = 'date_added DESC';
    final result = await db.query('plants', orderBy: orderBy);
    return result.map((json) => PlantModel.fromMap(json)).toList();
  }

  Future<int> update(PlantModel plant) async {
    final db = await instance.database;
    return db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
