import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('order_plan.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = join(dbPath, path);
    return await openDatabase(dbLocation, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE food (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      cost REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE order_plan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      target_cost REAL,
      food_items TEXT
    )
    ''');

    // Insert 20 sample food items
    await _insertSampleFoodItems(db);
  }

  Future<void> _insertSampleFoodItems(Database db) async {
    // List of food items
    List<Map<String, dynamic>> sampleFoods = [
      {'name': 'Pizza', 'cost': 8.99},
      {'name': 'Burger', 'cost': 5.99},
      {'name': 'Pasta', 'cost': 7.49},
      {'name': 'Salad', 'cost': 4.50},
      {'name': 'Sushi', 'cost': 12.99},
      {'name': 'Steak', 'cost': 15.99},
      {'name': 'Chicken Wings', 'cost': 6.99},
      {'name': 'Fries', 'cost': 2.99},
      {'name': 'Hot Dog', 'cost': 3.49},
      {'name': 'Ice Cream', 'cost': 3.99},
      {'name': 'Coffee', 'cost': 2.49},
      {'name': 'Tea', 'cost': 1.99},
      {'name': 'Smoothie', 'cost': 4.99},
      {'name': 'Soup', 'cost': 5.49},
      {'name': 'Tacos', 'cost': 6.49},
      {'name': 'Sandwich', 'cost': 4.99},
      {'name': 'Burrito', 'cost': 7.99},
      {'name': 'Wrap', 'cost': 5.99},
      {'name': 'Donuts', 'cost': 2.99},
      {'name': 'Cupcake', 'cost': 3.49},
    ];

    // Insert each food item into the database
    for (var food in sampleFoods) {
      await db.insert('food', food);
    }
  }

  // Query all food items
  Future<List<Map<String, dynamic>>> queryAllFood() async {
    final db = await instance.database;
    return await db.query('food');
  }

  Future<void> insertFood(Map<String, dynamic> food) async {
    final db = await instance.database;
    await db.insert('food', food);
  }

  // Query orders by date
  Future<List<Map<String, dynamic>>> queryOrderByDate(String date) async {
    final db = await instance.database;
    return await db.query('order_plan', where: 'date = ?', whereArgs: [date]);
  }

  // Insert an order plan
  Future<void> insertOrder(Map<String, dynamic> order) async {
    final db = await instance.database;
    await db.insert('order_plan', order);
  }
}
